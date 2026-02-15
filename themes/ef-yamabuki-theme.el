;;; ef-yamabuki-theme.el --- Legible light theme with golden yellow and warm accents -*- lexical-binding:t -*-

;;; Commentary:
;;
;; A custom light theme built on the `ef-themes' framework.
;; Yamabuki (山吹) --- golden yellow dominates, complemented by
;; fujipurple (藤紫) for types and enji (えんじ) for strings.
;; C-blend variant: warm, paper-like background with restrained accents.

;;; Code:

(require 'ef-themes)

(defconst ef-yamabuki-palette-partial
  '(;; Core backgrounds / foregrounds
    (cursor "#8B6914")
    (bg-main "#FEF9EF")
    (bg-dim "#FAF4E4")
    (bg-alt "#F5ECDA")
    (fg-main "#4D4538")
    (fg-dim "#7A6A48")
    (fg-alt "#8B7A40")
    (bg-active "#D0C4A0")
    (bg-inactive "#FCF6E8")
    (border "#E0D4B0")

    ;; Red family (diagnostics + string)
    (red "#C03030")
    (red-warmer "#C88020")
    (red-cooler "#9A3040")
    (red-faint "#A06050")

    ;; Green family (function/variable = 枯葉)
    (green "#A08020")
    (green-warmer "#AA7830")
    (green-cooler "#9A7A18")
    (green-faint "#B0A070")

    ;; Yellow family (keyword = ゴールド)
    (yellow "#B8860B")
    (yellow-warmer "#C89028")
    (yellow-cooler "#9A7A18")
    (yellow-faint "#B0A070")

    ;; Blue family (re-purposed: warm amber)
    (blue "#8B7A40")
    (blue-warmer "#9A7A18")
    (blue-cooler "#7A6A30")
    (blue-faint "#A09060")

    ;; Magenta family (type = 藤紫)
    (magenta "#7A5C8A")
    (magenta-warmer "#8A5C7A")
    (magenta-cooler "#6A5C90")
    (magenta-faint "#8A7A90")

    ;; Cyan family (re-purposed: warm tones)
    (cyan "#8A7020")
    (cyan-warmer "#AA7830")
    (cyan-cooler "#7A6A28")
    (cyan-faint "#9A8A60")

    ;; Intense backgrounds
    (bg-red-intense "#F0B0A0")
    (bg-green-intense "#E8DCA0")
    (bg-yellow-intense "#D4A830")
    (bg-blue-intense "#E8D8A8")
    (bg-magenta-intense "#E0C8D0")
    (bg-cyan-intense "#E8DCA0")

    ;; Subtle backgrounds
    (bg-red-subtle "#F0D8C8")
    (bg-green-subtle "#F0E8C8")
    (bg-yellow-subtle "#F0E0A0")
    (bg-blue-subtle "#EDE4C8")
    (bg-magenta-subtle "#E8E0E8")
    (bg-cyan-subtle "#F0E8D0")

    ;; Diff: added (黄色みの追加)
    (bg-added "#E8DCA0")
    (bg-added-faint "#F0E8C0")
    (bg-added-refine "#D8CC88")
    (fg-added "#5A4800")

    ;; Diff: changed
    (bg-changed "#F0E0A0")
    (bg-changed-faint "#F5ECC0")
    (bg-changed-refine "#E0D088")
    (fg-changed "#5A4800")

    ;; Diff: removed (暖色系ピンク)
    (bg-removed "#E8C8B0")
    (bg-removed-faint "#F0D8C8")
    (bg-removed-refine "#D8B098")
    (fg-removed "#901818")

    ;; UI chrome
    (bg-mode-line-active "#E0C060")
    (fg-mode-line-active "#4D4538")
    (bg-completion "#F0E0A0")
    (bg-hover "#E8D8A8")
    (bg-hover-secondary "#F0E8C8")
    (bg-hl-line "#F5ECDA")
    (bg-paren-match "#D8C888")
    (bg-err "#F0C8B0")
    (bg-warning "#E0C060")
    (bg-info "#E8DCA0")
    (bg-region "#E8D8A8")))

(defconst ef-yamabuki-palette-mappings-partial
  '(;; Status
    (err red)
    (warning red-warmer)
    (info yellow-cooler)

    ;; Links
    (fg-link magenta)
    (fg-link-visited magenta-faint)

    ;; Identifiers & prompt
    (name yellow)
    (keybind yellow-warmer)
    (identifier green-faint)
    (fg-prompt yellow)

    ;; Code syntax --- ③ C寄りブレンド
    (builtin yellow)
    (comment green-faint)
    (constant yellow-warmer)
    (fnname green)
    (fnname-call green-faint)
    (keyword yellow)
    (preprocessor yellow-cooler)
    (docstring green-faint)
    (string red-cooler)
    (type magenta)
    (variable green)
    (variable-use green-faint)
    (rx-backslash yellow-cooler)
    (rx-construct red-cooler)

    ;; Accents
    (accent-0 yellow)
    (accent-1 green)
    (accent-2 red-cooler)
    (accent-3 magenta)

    ;; Dates
    (date-common yellow-cooler)
    (date-deadline red)
    (date-deadline-subtle red-faint)
    (date-event fg-alt)
    (date-holiday red-warmer)
    (date-now fg-main)
    (date-range fg-alt)
    (date-scheduled yellow)
    (date-scheduled-subtle yellow-faint)
    (date-weekday yellow-cooler)
    (date-weekend green-faint)

    ;; Prose / markup
    (fg-prose-code magenta)
    (prose-done green)
    (fg-prose-macro yellow-warmer)
    (prose-metadata fg-dim)
    (prose-metadata-value fg-alt)
    (prose-table fg-alt)
    (prose-table-formula info)
    (prose-tag yellow-faint)
    (prose-todo red)
    (fg-prose-verbatim red-cooler)

    ;; Mail
    (mail-cite-0 yellow)
    (mail-cite-1 green)
    (mail-cite-2 red-cooler)
    (mail-cite-3 magenta)
    (mail-part yellow-faint)
    (mail-recipient yellow)
    (mail-subject red-cooler)
    (mail-other green-faint)

    ;; Search
    (bg-search-static bg-warning)
    (bg-search-current bg-yellow-intense)
    (bg-search-lazy bg-yellow-subtle)
    (bg-search-replace bg-red-intense)

    (bg-search-rx-group-0 bg-yellow-intense)
    (bg-search-rx-group-1 bg-green-intense)
    (bg-search-rx-group-2 bg-magenta-subtle)
    (bg-search-rx-group-3 bg-cyan-subtle)

    (bg-space-err bg-yellow-intense)

    ;; Line numbers & fringe
    (fringe bg-dim)
    (fg-line-number-active fg-alt)
    (bg-line-number-active bg-alt)
    (bg-line-number-inactive bg-dim)

    ;; Rainbow delimiters
    (rainbow-0 yellow)
    (rainbow-1 red-cooler)
    (rainbow-2 green)
    (rainbow-3 magenta)
    (rainbow-4 yellow-warmer)
    (rainbow-5 green-faint)
    (rainbow-6 magenta-faint)
    (rainbow-7 fg-alt)
    (rainbow-8 fg-dim)))

(defcustom ef-yamabuki-palette-overrides nil
  "Overrides for `ef-yamabuki-palette'.

Mirror the elements of the aforementioned palette, overriding
their value.

For overrides that are shared across all of the Ef themes,
refer to `ef-themes-common-palette-overrides'.

To preview the palette entries, use `ef-themes-preview-colors' or
`ef-themes-preview-colors-current' (read the documentation for
further details)."
  :group 'ef-themes
  :package-version '(ef-themes . "1.0.0")
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(ef-themes) Palette overrides"))

(defconst ef-yamabuki-palette
  (modus-themes-generate-palette
   ef-yamabuki-palette-partial
   nil
   nil
   (append ef-yamabuki-palette-mappings-partial ef-themes-palette-common)))

(defconst ef-yamabuki-custom-faces
  '(`(eldoc-highlight-function-argument
      ((,c :background ,bg-active :foreground ,fg-main :inherit bold)))))

(modus-themes-theme
 'ef-yamabuki
 'ef-themes
 "Legible light theme with golden yellow and warm accents (yamabuki)."
 'light
 'ef-yamabuki-palette
 nil
 'ef-yamabuki-palette-overrides
 'ef-yamabuki-custom-faces)

;;; ef-yamabuki-theme.el ends here
