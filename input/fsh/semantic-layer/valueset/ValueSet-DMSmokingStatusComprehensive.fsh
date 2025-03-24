ValueSet: DMSmokingStatusComprehensive
Title: "Smoking status comprehensive"
Description: """
(Clinical Focus: This set of values contains terms representing tobacco, e.g. nicotine, smoking, vaping, chew and snuff use or exposure.),
(Data Element Scope: The intent of this value set is to provide encoded terms representing nicotine exposure via products that may be smoked or taken in with other methods. The scope includes non-nicotene electronic cigarette terms. The scope does not include marijuana or illicit drugs that are smoked),
(Inclusion Criteria: Concepts from SCT's Tobacco Use and exposure hierarchy, electronic cigarette user hierarchy and appropriate codes from the event and situation hierarchies.),
(Exclusion Criteria: Terms reflecting absence of smoking)
"""

* ^experimental = false
* ^immutable = false

* include codes from system $sct
    where concept descendent-of #365980008
* include codes from system $sct
    where concept is-a #722499006
* include codes from system $sct
    where concept is-a #699009004
* include codes from system $sct
    where concept is-a #16090371000119103
* include $sct#16090771000119104
* include codes from system $sct
    where concept is-a #275105001