#lang brag
nd-program : (nd-short-slide | nd-long-slide-with-repetition | nd-long-slide-with-background-image | nd-long-slide |nd-command)*
nd-short-slide : /"slide" nd-text
nd-text : STRING
nd-long-slide-with-background-image: /"slide" /"with" /"background" /"image" nd-file (nd-slide-properties|nd-text|nd-para)+ /"end"
nd-long-slide-with-repetition : /"repeat" /"slide" INTEGER /"times" (nd-slide-properties|nd-text|nd-para)+ /"end"
nd-long-slide : /"slide" (nd-slide-properties|nd-text|nd-para)+ /"end"
@nd-slide-properties : nd-title-text | nd-footer-text | nd-center-text | nd-image | nd-spacer | nd-color | nd-item
@nd-file: STRING
@nd-title-text : [/"with"] /"title" STRING
nd-footer-text : [/"with"] /"footer" STRING
nd-center-text : [/"with"] /"text" nd-text
nd-image : /["with"] /"image" STRING
nd-spacer : /"space"
nd-color : /"color" STRING nd-text
nd-item : /"-" nd-text
@nd-command : nd-font-size | nd-font-name
nd-font-name : /["set"] /"font" /"face" STRING
nd-font-size : /["set"] /"font" /"size" INTEGER
nd-para : /"p"|/"¶"|/"§" STRING
