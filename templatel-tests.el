;;; templatel-tests --- Templating language for Emacs-Lisp; -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'templatel)

;; --- Error ---


;; --- Renderer --

(ert-deftest render-expr-logic ()
  (should (equal (templatel-render-string "{{ not not a }}" '(("a" . t))) "t"))
  (should (equal (templatel-render-string "{{ a or b }}" '(("a" . nil) ("b" . t))) "t"))
  (should (equal (templatel-render-string "{{ a or b }}" '(("a" . t) ("b" . nil))) "t"))
  (should (equal (templatel-render-string "{{ a or b }}" '(("a" . nil) ("b" . nil))) "nil"))
  (should (equal (templatel-render-string "{{ not a }}" '(("a" . nil))) "t"))
  (should (equal (templatel-render-string "{{ not not a }}" '(("a" . t))) "t"))
  (should (equal (templatel-render-string "{{ not a and not b }}"
                                          '(("a" . nil)
                                            ("b" . t)))
                 "nil"))
  (should (equal (templatel-render-string "{{ not a and not b }}"
                                          '(("a" . nil)
                                            ("b" . nil)))
                 "t")))

(ert-deftest render-expr-unary ()
  (should (equal (templatel-render-string "{{ +a }}" '(("a" . -10))) "10"))
  (should (equal (templatel-render-string "{{ +a }}" '(("a" . 10))) "10"))
  (should (equal (templatel-render-string "{{ -a }}" '(("a" . -10))) "10"))
  (should (equal (templatel-render-string "{{ -a }}" '(("a" . 10))) "-10")))

(ert-deftest render-expr-all-bitlogic ()
  (should (equal (templatel-render-string "{{ a & 0b11 }}" '(("a" . 10))) "2"))
  (should (equal (templatel-render-string "{{ a || 0b1 }}" '(("a" . 10))) "11"))
  (should (equal (templatel-render-string "{{ a ^ 0b11 }}" '(("a" . 10))) "9"))
  (should (equal (templatel-render-string "{{ ~a }}" '(("a" . 10))) "-11")))

(ert-deftest render-expr-all-cmp ()
  (should (equal (templatel-render-string "{{ a == 10 }}" '(("a" . 10))) "t"))
  (should (equal (templatel-render-string "{{ a == 11 }}" '(("a" . 10))) "nil"))
  (should (equal (templatel-render-string "{{ a != 11 }}" '(("a" . 10))) "t"))
  (should (equal (templatel-render-string "{{ a != 10 }}" '(("a" . 10))) "nil"))
  (should (equal (templatel-render-string "{{ a >= 10 }}" '(("a" . 10))) "t"))
  (should (equal (templatel-render-string "{{ a >= 11 }}" '(("a" . 10))) "nil"))
  (should (equal (templatel-render-string "{{ a <= 11 }}" '(("a" . 10))) "t"))
  (should (equal (templatel-render-string "{{ a <=  9 }}" '(("a" . 10))) "nil"))
  (should (equal (templatel-render-string "{{ a  < 11 }}" '(("a" . 10))) "t"))
  (should (equal (templatel-render-string "{{ a  < 10 }}" '(("a" . 10))) "nil"))
  (should (equal (templatel-render-string "{{ a  >  9 }}" '(("a" . 10))) "t"))
  (should (equal (templatel-render-string "{{ a  > 10 }}" '(("a" . 10))) "nil")))

(ert-deftest render-if-elif-expr-cmp ()
  (should (equal (templatel-render-string
                  "{% if a > 10 %}Big{% elif a > 5 %}Med{% else %}Small{% endif %}"
                  '(("a" . 11)))
                 "Big"))
  (should (equal (templatel-render-string
                  "{% if a > 10 %}Big{% elif a > 5 %}Med{% else %}Small{% endif %}"
                  '(("a" . 7)))
                 "Med"))
  (should (equal (templatel-render-string
                  "{% if a > 10 %}Big{% elif a > 5 %}Med{% else %}Small{% endif %}"
                  '(("a" . 4)))
                 "Small")))

(ert-deftest render-if-else-expr-cmp ()
  (should (equal (templatel-render-string
                  "{% if a > 3 %}{{ (2 + 3) * a }}{% else %}ecase{% endif %}"
                  '(("a" . 2)))
                 "ecase")))

(ert-deftest render-if-expr-cmp ()
  (should (equal (templatel-render-string
                  "{% if a > 3 %}{{ (2 + 3) * a }}{% endif %}"
                  '(("a" . 2)))
                 ""))
  (should (equal (templatel-render-string
                  "{% if a > 3 %}{{ (2 + 3) * a }}{% endif %}"
                  '(("a" . 10)))
                 "50")))

(ert-deftest render-expr-math-paren ()
  (should (equal (templatel-render-string
                  "{{ (2 + 3) * 4 }}"
                  '())
                 "20")))

(ert-deftest render-expr-math-mix ()
  (should (equal (templatel-render-string
                  "{{ 2 + 3 * 4 }}"
                  '())
                 "14")))

(ert-deftest render-expr-math-div ()
  (should (equal (templatel-render-string
                  "{{ 150 / 3 }}"
                  '())
                 "50")))

(ert-deftest render-expr-math-mul ()
  (should (equal (templatel-render-string
                  "{{ 2 * 3 * 4 }}"
                  '())
                 "24")))

(ert-deftest render-expr-math-sub ()
  (should (equal (templatel-render-string
                  "{{ 150 - 3 }}"
                  '())
                 "147")))

(ert-deftest render-expr-math-sub ()
  (should (equal (templatel-render-string
                  "{{ 150 + 3 }}"
                  '())
                 "153")))

(ert-deftest render-expr-filter-pipe ()
  (should (equal (templatel-render-string
                  "Awww {{ qts|sum|plus1 }}."
                  '(("qts" . (1 2 3 4 5))))
                 "Awww 16.")))

(ert-deftest render-expr-filter-upper ()
  (should (equal (templatel-render-string
                  "Awww {{ user.name|upper }}."
                  '(("user" . (("name" . "Gnu")))))
                 "Awww GNU.")))

(ert-deftest render-expr-filter-int ()
  (should (equal (templatel-render-string
                  "You won {{ user.byte|int(16) }} in bars of gold"
                  '(("user" . (("byte" . "0xFF")))))
                 "You won 255 in bars of gold")))

(ert-deftest render-expr-attr ()
  (should (equal (templatel-render-string
                  "Hi {{ user.name }}, happy {{ user.greeting }}"
                  '(("user" . (("name" . "Gnu")
                               ("greeting" . "Hacking")))))
                 "Hi Gnu, happy Hacking")))

(ert-deftest render-expr-string ()
  (should (equal (templatel-render-string "{{ \"something\" }}" '()) "something")))

(ert-deftest render-expr-number-bin ()
  (should (equal (templatel-render-string "{{ 0b1010 }}" '()) "10")))

(ert-deftest render-expr-number-hex ()
  (should (equal (templatel-render-string "{{ 0xFF }}" '()) "255")))

(ert-deftest render-expr-number ()
  (should (equal (templatel-render-string "{{ 1280 }}" '()) "1280")))

(ert-deftest render-template-forloop ()
  (should (equal
           (templatel-render-string
            "{% for name in names %}{{ name }} {% endfor %}"
            '(("names" . ("One" "Two" "Three"))))
           "One Two Three ")))

(ert-deftest render-template-elif0 ()
  (should
   (equal
    (templatel-render-string
"<h1>Hello
{% if one %}
  {{ name1 }}
{% elif two %}
  {{ name2 }}
{% elif three %}
  Three
{% else %}
  Four
{% endif %}
</h1>
"
     '(("name1" . "Emacs")
       ("name2" . "Gnu")
       ("one" . nil)
       ("two" . t)))
    "<h1>Hello\n\n  Gnu\n\n</h1>\n")))

(ert-deftest render-template-if-else-n ()
  (should
   (equal
    (templatel-render-string
     "<h1>Hello {% if enabled %}{{ name }}{% else %}Non-MX{% endif %}</h1>"
     '(("name" . "Emacs")
       ("enabled" . nil)))
    "<h1>Hello Non-MX</h1>")))

(ert-deftest render-template-if-else-t ()
  (should
   (equal
    (templatel-render-string
     "<h1>Hello {% if enabled %}{{ name }}{% else %}Non-Emacs{% endif %}</h1>"
     '(("name" . "Emacs")
       ("enabled" . t)))
    "<h1>Hello Emacs</h1>")))

(ert-deftest render-template-if-true ()
  (should
   (equal
    (templatel-render-string
     "<h1>Hello {% if enabled %}{{ name }}{% endif %}</h1>"
     '(("name" . "Emacs")
       ("enabled" . t)))
    "<h1>Hello Emacs</h1>")))

(ert-deftest render-template-if-false ()
  (should
   (equal
    (templatel-render-string
     "<h1>Hello {% if enabled %}{{ name }}{% endif %}</h1>"
     '(("name" . "Emacs")
       ("enabled" . nil)))
    "<h1>Hello </h1>")))

(ert-deftest render-template-variable ()
  (should (equal
           (templatel-render-string "<h1>Hello {{ name }}</h1>" '(("name" . "Emacs")))
           "<h1>Hello Emacs</h1>")))

(ert-deftest render-template ()
  (should (equal
           (templatel-render-string "<h1>Hello Emacs</h1>" nil)
           "<h1>Hello Emacs</h1>")))



;; --- Filters ---


(ert-deftest filter-upper ()
  (should (equal (filters/upper "stuff") "STUFF")))

(ert-deftest filter-lower ()
  (should (equal (filters/lower "STUFF") "stuff")))



;; --- Compiler ---

(ert-deftest compile-template ()
  (let* ((s (scanner/new "<h1>Hello Emacs</h1>"))
         (tree (parser/template s)))
    (should (equal
             (compiler/run tree)
             '((insert "<h1>Hello Emacs</h1>"))))))

(ert-deftest compile-text ()
  (let* ((s (scanner/new "<h1>Hello Emacs</h1>"))
         (tree (parser/text s)))
    (should (equal
             (compiler/run tree)
             '(insert "<h1>Hello Emacs</h1>")))))



;; --- Parser & Scanner ---

(ert-deftest template-for ()
  (let* ((s (scanner/new "
{% for name in names %}
  {{ name }}
{% endfor %}
"))
         (txt (parser/template s)))
    (should (equal
             txt
             '("Template"
               ("Text" . "\n")
               ("ForStatement"
                ("Expr" ("Element" ("Identifier" . "name")))
                ("Expr" ("Element" ("Identifier" . "names")))
                ("Template"
                 ("Text" . "\n  ")
                 ("Expression"
                  ("Expr"
                   ("Element"
                    ("Identifier" . "name"))))
                 ("Text" . "\n")))
               ("Text" . "\n"))))))

(ert-deftest template-elif ()
  (let* ((s (scanner/new "
{% if one %}
  One
{% elif two %}
  Two
{% elif three %}
  Three
{% else %}
  Four
{% endif %}
"))
         (txt (parser/template s)))
    (should (equal
             txt
             '("Template"
               ("Text" . "\n")
               ("IfElif"
                ("Expr"
                 ("Element"
                  ("Identifier" . "one")))
                ("Template" ("Text" . "\n  One\n"))
                (("Elif"
                  ("Expr"
                   ("Element"
                    ("Identifier" . "two")))
                  ("Template" ("Text" . "\n  Two\n")))
                 ("Elif" ("Expr" ("Element" ("Identifier" . "three")))
                  ("Template" ("Text" . "\n  Three\n"))))
                ("Else" ("Template" ("Text" . "\n  Four\n"))))
               ("Text" . "\n"))))))

(ert-deftest template-if-else ()
  (let* ((s (scanner/new "{% if show %}{{ show }}{% else %}Hide{% endif %}"))
         (txt (parser/template s)))
    (should (equal
             txt
             '("Template"
               ("IfElse"
                ("Expr"
                 ("Element"
                  ("Identifier" . "show")))
                ("Template"
                 ("Expression"
                  ("Expr"
                   ("Element"
                    ("Identifier" . "show")))))
                ("Else"
                 ("Template" ("Text" . "Hide")))))))))

(ert-deftest template-if ()
  (let* ((s (scanner/new "{% if show %}{{ show }}{% endif %}"))
         (txt (parser/template s)))
    (should (equal
             txt
             '("Template"
               ("IfStatement"
                ("Expr"
                 ("Element"
                  ("Identifier" . "show")))
                ("Template"
                 ("Expression"
                  ("Expr"
                   ("Element"
                    ("Identifier" . "show")))))))))))

(ert-deftest template-expr-binop ()
  (let* ((s (scanner/new "Hello, {{ 1 * 2 }}!"))
         (tree (parser/template s)))
    (should (equal
             tree
             '("Template"
               ("Text" . "Hello, ")
               ("Expression"
                ("Expr"
                 ("BinOp"
                  ("Element" ("Number" . 1))
                  ("*" "Element" ("Number" . 2)))))
               ("Text" . "!"))))))

(ert-deftest template-variable ()
  (let* ((s (scanner/new "Hello, {{ name }}!"))
         (tree (parser/template s)))
    (should (equal
             tree
             '("Template"
               ("Text" . "Hello, ")
               ("Expression"
                ("Expr"
                 ("Element"
                  ("Identifier" . "name"))))
               ("Text" . "!"))))))

(ert-deftest expr-value-string ()
  (let ((s (scanner/new "\"fun with Emacs\"")))
    (should (equal
             (parser/value s)
             '("String" . "fun with Emacs")))))

(ert-deftest expr-value-number ()
  (let ((s (scanner/new "325")))
    (should (equal
             (parser/value s)
             '("Number" . 325)))))

(ert-deftest expr-value-number-bin ()
  (let ((s (scanner/new "0b1010")))
    (should (equal
             (parser/value s)
             '("Number" . 10)))))

(ert-deftest expr-value-number-hex ()
  (let ((s (scanner/new "0xff")))
    (should (equal
             (parser/value s)
             '("Number" . 255)))))

(ert-deftest expr-value-bool-true ()
  (let ((s (scanner/new "true")))
    (should (equal
             (parser/value s)
             '("Bool" . t)))))

(ert-deftest expr-value-bool-false-with-comment ()
  (let ((s (scanner/new "false {# not important #}")))
    (should (equal
             (parser/value s)
             '("Bool" . nil)))))

;;; templatel-tests.el ends here
