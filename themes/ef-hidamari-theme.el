;;; ef-hidamari-theme.el --- Light theme with warm light and airy elegance -*- lexical-binding:t -*-

;;; Commentary:
;;
;; A custom light theme built on the `ef-themes' framework.
;; The palette follows a "sunlit elegance" direction:
;; yellow, gold, white, and beige form the core, while sky blue and
;; lavender act as restrained supporting accents.

;;; Code:

(require 'ef-themes)

(defconst ef-hidamari-palette-partial
  '(;; Core backgrounds / foregrounds
    (cursor "#8E6C00")
    (bg-main "#FFFDF8")
    (bg-dim "#F8F2E6")
    (bg-alt "#F2E8D8")
    (fg-main "#4A4032")
    (fg-dim "#726452")
    (fg-alt "#8A7A66")
    (bg-active "#E8D7A5")
    (bg-inactive "#FCF8EF")
    (border "#E4D7BC")

    ;; Red family: warm rose and garnet
    (red "#B94C5E")
    (red-warmer "#C97B43")
    (red-cooler "#954356")
    (red-faint "#BF9196")

    ;; Green family: subdued olive to avoid dominating the palette
    (green "#8E8960")
    (green-warmer "#A28B57")
    (green-cooler "#6F7A62")
    (green-faint "#B3AA87")

    ;; Yellow family: primary lucky axis
    (yellow "#B88A00")
    (yellow-warmer "#D09E1C")
    (yellow-cooler "#8C7000")
    (yellow-faint "#C5B06E")

    ;; Blue family: airy structure with quiet navy depth
    (blue "#58769B")
    (blue-warmer "#7691B6")
    (blue-cooler "#3F5C80")
    (blue-faint "#9EB1C7")

    ;; Magenta family: lavender and violet support
    (magenta "#8A6AA8")
    (magenta-warmer "#A17CB5")
    (magenta-cooler "#6D5A8A")
    (magenta-faint "#B8A8C9")

    ;; Cyan family: clear sky highlight
    (cyan "#5D9EBE")
    (cyan-warmer "#81B8D4")
    (cyan-cooler "#417F9B")
    (cyan-faint "#A6CDDF")

    ;; Intense backgrounds
    (bg-red-intense "#F5CDD4")
    (bg-green-intense "#E9E0B7")
    (bg-yellow-intense "#F2D97A")
    (bg-blue-intense "#D3E5F2")
    (bg-magenta-intense "#E7DBF1")
    (bg-cyan-intense "#D9EEF7")

    ;; Subtle backgrounds
    (bg-red-subtle "#FAE7EA")
    (bg-green-subtle "#F3EED6")
    (bg-yellow-subtle "#FAF0C7")
    (bg-blue-subtle "#EAF2F8")
    (bg-magenta-subtle "#F1EBF7")
    (bg-cyan-subtle "#EBF7FB")

    ;; Diff
    (bg-added "#E8F4FA")
    (bg-added-faint "#F2F9FC")
    (bg-added-refine "#BFDFEE")
    (fg-added "#245D77")

    (bg-changed "#FAF0C7")
    (bg-changed-faint "#FCF6DD")
    (bg-changed-refine "#E9D48A")
    (fg-changed "#5E4A00")

    (bg-removed "#F6DADF")
    (bg-removed-faint "#FBECF0")
    (bg-removed-refine "#E5B8C0")
    (fg-removed "#7A2735")

    ;; UI chrome
    (bg-mode-line-active "#E7CF72")
    (fg-mode-line-active "#453B2F")
    (bg-completion "#F8EFCA")
    (bg-hover "#EAF3F9")
    (bg-hover-secondary "#F1EAF7")
    (bg-hl-line "#FBF6EC")
    (bg-paren-match "#DDECF5")
    (bg-err "#F5D7DE")
    (bg-warning "#F2E1A0")
    (bg-info "#DDEFF7")
    (bg-region "#E8E0F3")))

(defconst ef-hidamari-palette-mappings-partial
  '(;; Status
    (err red)
    (warning yellow-warmer)
    (info cyan-cooler)

    ;; Links
    (fg-link cyan-cooler)
    (fg-link-visited magenta-cooler)

    ;; Identifiers & prompt
    (name yellow)
    (keybind yellow-warmer)
    (identifier blue-faint)
    (fg-prompt yellow-cooler)

    ;; Code syntax
    (builtin yellow)
    (comment fg-alt)
    (constant yellow-warmer)
    (fnname cyan-cooler)
    (fnname-call cyan)
    (keyword yellow-cooler)
    (preprocessor blue)
    (docstring red-faint)
    (string red-cooler)
    (type magenta)
    (variable blue-cooler)
    (variable-use blue)
    (rx-backslash magenta-cooler)
    (rx-construct red-cooler)

    ;; Accents
    (accent-0 yellow)
    (accent-1 cyan)
    (accent-2 red)
    (accent-3 magenta)

    ;; Dates
    (date-common blue)
    (date-deadline red)
    (date-deadline-subtle red-faint)
    (date-event fg-alt)
    (date-holiday red-warmer)
    (date-now fg-main)
    (date-range fg-alt)
    (date-scheduled yellow)
    (date-scheduled-subtle yellow-faint)
    (date-weekday blue-cooler)
    (date-weekend magenta-faint)

    ;; Prose / markup
    (fg-prose-code magenta-cooler)
    (prose-done cyan-cooler)
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
    (mail-cite-1 cyan)
    (mail-cite-2 red)
    (mail-cite-3 magenta)
    (mail-part blue-faint)
    (mail-recipient cyan-cooler)
    (mail-subject red-cooler)
    (mail-other fg-alt)

    ;; Search
    (bg-search-static bg-warning)
    (bg-search-current bg-yellow-intense)
    (bg-search-lazy bg-yellow-subtle)
    (bg-search-replace bg-red-intense)

    (bg-search-rx-group-0 bg-yellow-intense)
    (bg-search-rx-group-1 bg-cyan-intense)
    (bg-search-rx-group-2 bg-magenta-intense)
    (bg-search-rx-group-3 bg-blue-intense)

    (bg-space-err bg-yellow-intense)

    ;; Line numbers & fringe
    (fringe bg-dim)
    (fg-line-number-active fg-alt)
    (bg-line-number-active bg-alt)
    (bg-line-number-inactive bg-dim)

    ;; Rainbow delimiters
    (rainbow-0 yellow)
    (rainbow-1 cyan)
    (rainbow-2 red)
    (rainbow-3 magenta)
    (rainbow-4 yellow-warmer)
    (rainbow-5 blue)
    (rainbow-6 magenta-faint)
    (rainbow-7 fg-alt)
    (rainbow-8 fg-dim)))

(defcustom ef-hidamari-palette-overrides nil
  "Overrides for `ef-hidamari-palette'."
  :group 'ef-themes
  :package-version '(ef-themes . "1.0.0")
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(ef-themes) Palette overrides"))

(defconst ef-hidamari-palette
  (modus-themes-generate-palette
   ef-hidamari-palette-partial
   nil
   nil
   (append ef-hidamari-palette-mappings-partial ef-themes-palette-common)))

(defconst ef-hidamari-custom-faces
  '(`(eldoc-highlight-function-argument
      ((,c :background ,bg-active :foreground ,fg-main :inherit bold)))))

(modus-themes-theme
 'ef-hidamari
 'ef-themes
 "Light theme with warm light and airy elegance."
 'light
 'ef-hidamari-palette
 nil
 'ef-hidamari-palette-overrides
 'ef-hidamari-custom-faces)

;;; ef-hidamari-theme.el ends here
