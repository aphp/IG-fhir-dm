# GÉNÉRATION FHIR QuestionnaireResponse

## CONTEXTE
Tu es un expert en interopérabilité FHIR. Tu disposes de données cliniques pour 10 patients (numérotés de 1 à 10) incluant :
- Actes médicaux
- Diagnostics
- Résultats de biologie
- Séjours d'hospitalisation
- Prescriptions
- Administrations médicamenteuses
- Dossiers de soins
- Style de vie

## OBJECTIF

Générer UNE SEULE instance de ressource FHIR **QuestionnaireResponse** conforme à la spécification FHIR R4 pour le patient spécifié.

## MODÈLE DE QuestionnaireResponse (EXEMPLE)
```json
{
  "resourceType": "QuestionnaireResponse",
  "id": "cas-9-usage-core",
  "status": "completed",
  "authored": "2025-10-14T16:14:57.160Z",
  "questionnaire": "https://interop.aphp.fr/ig/fhir/dm/Questionnaire/UsageCore",
  "item": [
    {
      "linkId": "4647259356106",
      "text": "Données socio-démographiques",
      "item": [
        {
          "linkId": "2958000860428",
          "text": "Identité patient",
          "item": [
            {
              "answer": [
                {
                  "valueString": "Blanc"
                }
              ],
              "linkId": "8605698058770",
              "text": "Nom patient"
            },
            {
              "answer": [
                {
                  "valueString": "Isabelle"
                }
              ],
              "linkId": "6214879623503",
              "text": "Prénom patient"
            },
            {
              "answer": [
                {
                  "valueString": "278056432187654"
                }
              ],
              "linkId": "5711960356160",
              "text": "Numéro d'inscription au Répertoire (NIR)"
            },
            {
              "answer": [
                {
                  "valueDate": "1978-05-06"
                }
              ],
              "linkId": "5036133558154",
              "text": "Date de naissance"
            }
          ]
        },
        {
          "linkId": "5491974639955",
          "text": "Environnement",
          "item": [
            {
              "linkId": "3816475533472",
              "text": "Géocodage",
              "item": [
                {
                  "answer": [
                    {
                      "valueDecimal": 48.8499
                    }
                  ],
                  "linkId": "3709843054556",
                  "text": "Latitude"
                },
                {
                  "answer": [
                    {
                      "valueDecimal": 2.2943
                    }
                  ],
                  "linkId": "7651448032665",
                  "text": "Longitude"
                },
                {
                  "answer": [
                    {
                      "valueDate": "2024-01-01"
                    }
                  ],
                  "linkId": "1185653257776",
                  "text": "Date du recueil de l'information"
                }
              ]
            },
            {
              "linkId": "7621032273792",
              "text": "IRIS",
              "answer": [
                {
                  "valueCoding": {
                    "system": "https://inse.fr/IRIS-cs",
                    "code": "751151001",
                    "display": "GRENELLE"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueDate": "2024-01-01"
                        }
                      ],
                      "linkId": "4999580038872",
                      "text": "Date du recueil de l'information"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "linkId": "2825244231605",
      "text": "Données PMSI",
      "item": [
        {
          "answer": [
            {
              "valueCoding": {
                "system": "https://interop.aphp.fr/ig/fhir/dm/CodeSystem/DpiGender",
                "code": "f",
                "display": "Femme"
              }
            }
          ],
          "linkId": "3894630481120",
          "text": "Sexe"
        },
        {
          "answer": [
            {
              "valueCoding": {
                "system": "https://atih.sante.fr/CodesGeographiques-cs",
                "code": "75015",
                "display": "Paris 15ème arrondissement"
              },
              "item": [
                {
                  "answer": [
                    {
                      "valueDate": "2024-01-01"
                    }
                  ],
                  "linkId": "1537511139540",
                  "text": "Date du recueil de l'information"
                }
              ]
            }
          ],
          "linkId": "2446369196222",
          "text": "Code géographique de résidence"
        },
        {
          "linkId": "9391816419630",
          "text": "Diagnostics",
          "item": [
            {
              "answer": [
                {
                  "valueDate": "2024-01-15"
                }
              ],
              "linkId": "7114466839467",
              "text": "Date du recueil de l'information"
            },
            {
              "answer": [
                {
                  "valueCoding": {
                    "display": "DP"
                  }
                }
              ],
              "linkId": "6427586743735",
              "text": "Type de diagnostic"
            },
            {
              "answer": [
                {
                  "valueCoding": {
                    "code": "R18",
                    "display": "Ascite"
                  }
                }
              ],
              "linkId": "5505101189372",
              "text": "Diagnostique"
            }
          ]
        },
        {
          "linkId": "9391816419630",
          "text": "Diagnostics",
          "item": [
            {
              "answer": [
                {
                  "valueDate": "2024-01-15"
                }
              ],
              "linkId": "7114466839467",
              "text": "Date du recueil de l'information"
            },
            {
              "answer": [
                {
                  "valueCoding": {
                    "display": "DAS"
                  }
                }
              ],
              "linkId": "6427586743735",
              "text": "Type de diagnostic"
            },
            {
              "answer": [
                {
                  "valueCoding": {
                    "code": "K70.3",
                    "display": "Cirrhose alcoolique du foie"
                  }
                }
              ],
              "linkId": "5505101189372",
              "text": "Diagnostique"
            }
          ]
        },
        {
          "linkId": "591926901726",
          "text": "Actes",
          "item": [
            {
              "answer": [
                {
                  "valueDate": "2024-01-15"
                }
              ],
              "linkId": "9436509453137",
              "text": "Date du recueil de l'information"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-13T12:15:00.000Z"
                }
              ],
              "linkId": "5066866286682",
              "text": "Date de l'acte"
            },
            {
              "answer": [
                {
                  "valueCoding": {
                    "code": "HPHB003",
                    "system": "https://smt.esante.gouv.fr/terminologie-ccam",
                    "display": "Ponction d'un épanchement péritonéal, par voie transcutanée"
                  }
                }
              ],
              "linkId": "7758110033600",
              "text": "Acte"
            }
          ]
        },
        {
          "linkId": "591926901726",
          "text": "Actes",
          "item": [
            {
              "answer": [
                {
                  "valueDate": "2024-01-15"
                }
              ],
              "linkId": "9436509453137",
              "text": "Date du recueil de l'information"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-14T07:00:00.000Z"
                }
              ],
              "linkId": "5066866286682",
              "text": "Date de l'acte"
            },
            {
              "answer": [
                {
                  "valueCoding": {
                    "code": "HEQE002",
                    "system": "https://smt.esante.gouv.fr/terminologie-ccam",
                    "display": "Endoscopie oeso-gastro-duodénale"
                  }
                }
              ],
              "linkId": "7758110033600",
              "text": "Acte"
            }
          ]
        },
        {
          "answer": [
            {
              "valueDate": "2024-01-13"
            }
          ],
          "linkId": "5991443718282",
          "text": "Date de début de séjour"
        },
        {
          "answer": [
            {
              "valueDate": "2024-01-14"
            }
          ],
          "linkId": "6114780320846",
          "text": "Date de fin de séjour"
        },
        {
          "answer": [
            {
              "valueCoding": {
                "code": "8",
                "display": "Domicile"
              }
            }
          ],
          "linkId": "6172398101212",
          "text": "Mode d'entrée du séjour"
        },
        {
          "answer": [
            {
              "valueCoding": {
                "code": "8",
                "display": "Domicile"
              }
            }
          ],
          "linkId": "3354867075704",
          "text": "Mode de sortie du séjour"
        }
      ]
    },
    {
      "linkId": "7702944131447",
      "text": "Biologie",
      "item": [
        {
          "linkId": "419282985970",
          "text": "Hémogramme",
          "item": [
            {
              "linkId": "658898841893",
              "text": "Taux de prothrombine (TP)",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 80,
                    "unit": "%"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueCoding": {
                            "system": "http://loinc.org",
                            "code": "5894-1",
                            "display": "Temps de quick Patient (%) [Temps relatif] Plasma pauvre en plaquettes ; Numérique ; Coagulation"
                          }
                        }
                      ],
                      "linkId": "219513623269",
                      "text": "code loinc"
                    },
                    {
                      "answer": [
                        {
                          "valueDateTime": "2024-01-13T07:30:00.000Z"
                        }
                      ],
                      "linkId": "379165914699",
                      "text": "Date et heure du prélèvement"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 50,
                            "unit": "%"
                          }
                        }
                      ],
                      "linkId": "253311419093",
                      "text": "Borne inférieure de normalité du résultat"
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "linkId": "796308115381",
          "text": "Bilan hépatique",
          "item": [
            {
              "linkId": "715226319725",
              "text": "Aspartate aminotransférase (AST)",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 37,
                    "unit": "UI/L"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueCoding": {
                            "system": "http://loinc.org",
                            "code": "1920-8",
                            "display": "Aspartate aminotransférase [Catalytique/Volume] Sérum/Plasma ; Numérique"
                          }
                        }
                      ],
                      "linkId": "757363598159",
                      "text": "code loinc"
                    },
                    {
                      "answer": [
                        {
                          "valueDateTime": "2024-01-13T07:30:00.000Z"
                        }
                      ],
                      "linkId": "884511824515",
                      "text": "Date et heure du prélèvement"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 6,
                            "unit": "UI/L"
                          }
                        }
                      ],
                      "linkId": "584123691679",
                      "text": "Borne inférieure de normalité du résultat"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 25,
                            "unit": "UI/L"
                          }
                        }
                      ],
                      "linkId": "935082505777",
                      "text": "Borne supérieure de normalité du résultat"
                    }
                  ]
                }
              ]
            },
            {
              "linkId": "876439410327",
              "text": "Alanine aminotransférase (ALT)",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 38,
                    "unit": "UI/L"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueCoding": {
                            "system": "http://loinc.org",
                            "code": "1742-6",
                            "display": "Alanine aminotransférase [Catalytique/Volume] Sérum/Plasma ; Numérique"
                          }
                        }
                      ],
                      "linkId": "698926487710",
                      "text": "code loinc"
                    },
                    {
                      "answer": [
                        {
                          "valueDateTime": "2024-01-13T07:30:00.000Z"
                        }
                      ],
                      "linkId": "881040341675",
                      "text": "Date et heure du prélèvement"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 6,
                            "unit": "UI/L"
                          }
                        }
                      ],
                      "linkId": "581883215378",
                      "text": "Borne inférieure de normalité du résultat"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 25,
                            "unit": "UI/L"
                          }
                        }
                      ],
                      "linkId": "594636277238",
                      "text": "Borne supérieure de normalité du résultat"
                    }
                  ]
                }
              ]
            },
            {
              "linkId": "287545455976",
              "text": "Gamma-glutamyl transférase (GGT)",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 30,
                    "unit": "UI/L"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueCoding": {
                            "system": "http://loinc.org",
                            "code": "2324-2",
                            "display": "Gamma glutamyltransférase [Catalytique/Volume] Sérum/Plasma ; Numérique"
                          }
                        }
                      ],
                      "linkId": "688754894578",
                      "text": "code loinc"
                    },
                    {
                      "answer": [
                        {
                          "valueDateTime": "2024-01-13T07:30:00.000Z"
                        }
                      ],
                      "linkId": "191793018592",
                      "text": "Date et heure du prélèvement"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 35,
                            "unit": "UI/L"
                          }
                        }
                      ],
                      "linkId": "930639734905",
                      "text": "Borne supérieure de normalité du résultat"
                    }
                  ]
                }
              ]
            },
            {
              "linkId": "508269571594",
              "text": "Phosphatases alcalines (PAL)",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 100,
                    "unit": "U/L"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueCoding": {
                            "system": "http://loinc.org",
                            "code": "6768-6",
                            "display": "Phosphatases alcalines [Catalytique/Volume] Sérum/Plasma ; Numérique"
                          }
                        }
                      ],
                      "linkId": "726897332003",
                      "text": "code loinc"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 35,
                            "unit": "U/L"
                          }
                        }
                      ],
                      "linkId": "334934131934",
                      "text": "Borne inférieure de normalité du résultat"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 104,
                            "unit": "U/L"
                          }
                        }
                      ],
                      "linkId": "989367019315",
                      "text": "Borne supérieure de normalité du résultat"
                    }
                  ]
                }
              ]
            },
            {
              "linkId": "927344090061",
              "text": "Bilirubine totale",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 25,
                    "unit": "umol/L"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueCoding": {
                            "system": "http://loinc.org",
                            "code": "1975-2",
                            "display": "Bilirubine [Masse/Volume] Sérum/Plasma ; Numérique"
                          }
                        }
                      ],
                      "linkId": "657001208566",
                      "text": "code loinc"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 5,
                            "unit": "umol/L"
                          }
                        }
                      ],
                      "linkId": "439478297194",
                      "text": "Borne inférieure de normalité du résultat"
                    },
                    {
                      "answer": [
                        {
                          "valueQuantity": {
                            "value": 21,
                            "unit": "umol/L"
                          }
                        }
                      ],
                      "linkId": "363409811810",
                      "text": "Borne supérieure de normalité du résultat"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "linkId": "817801935685",
      "text": "Exposition médicamenteuse",
      "item": [
        {
          "linkId": "156631794800",
          "text": "Médicament prescrit",
          "answer": [
            {
              "valueString": "furosémide 40mg",
              "item": [
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-atc",
                        "code": "C03CA01",
                        "display": "furosémide"
                      }
                    }
                  ],
                  "linkId": "1923143398283",
                  "text": "codification"
                },
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-standardterms",
                        "code": "90001146",
                        "display": "Oral"
                      }
                    }
                  ],
                  "linkId": "387026794874",
                  "text": "Voie d'administration"
                }
              ]
            }
          ]
        },
        {
          "linkId": "6348237104421",
          "text": "Posologie (à détailler)",
          "item": [
            {
              "answer": [
                {
                  "valueDate": "2024-01-13"
                }
              ],
              "linkId": "316347573327",
              "text": "Date de début de la prescription"
            },
            {
              "answer": [
                {
                  "valueDate": "2024-02-13"
                }
              ],
              "linkId": "429570775935",
              "text": "Date de fin de la prescription"
            }
          ]
        },
        {
          "linkId": "266852453304",
          "text": "Médicament administré",
          "answer": [
            {
              "valueString": "furosémide 40mg",
              "item": [
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-atc",
                        "code": "C03CA01",
                        "display": "furosémide"
                      }
                    }
                  ],
                  "linkId": "631972144976",
                  "text": "codification"
                },
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-standardterms",
                        "code": "90001146",
                        "display": "Oral"
                      }
                    }
                  ],
                  "linkId": "811931484859",
                  "text": "Voie d'administration"
                }
              ]
            }
          ]
        },
        {
          "linkId": "5720103839343",
          "text": "Dosage",
          "item": [
            {
              "answer": [
                {
                  "valueQuantity": {
                    "value": 40,
                    "unit": "mg"
                  }
                }
              ],
              "linkId": "4765772671997",
              "text": "Quantité administrée"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-13T07:00:00.000Z"
                }
              ],
              "linkId": "1443558617577",
              "text": "Date et heure de début d'administration"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-13T07:05:00.000Z"
                }
              ],
              "linkId": "780829110731",
              "text": "Date et heure de fin d'administration"
            }
          ]
        },
        {
          "linkId": "5720103839343",
          "text": "Dosage",
          "item": [
            {
              "answer": [
                {
                  "valueQuantity": {
                    "value": 40,
                    "unit": "mg"
                  }
                }
              ],
              "linkId": "4765772671997",
              "text": "Quantité administrée"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-14T07:00:00.000Z"
                }
              ],
              "linkId": "1443558617577",
              "text": "Date et heure de début d'administration"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-14T07:05:00.000Z"
                }
              ],
              "linkId": "780829110731",
              "text": "Date et heure de fin d'administration"
            }
          ]
        }
      ]
    },
    {
      "linkId": "817801935685",
      "text": "Exposition médicamenteuse",
      "item": [
        {
          "linkId": "156631794800",
          "text": "Médicament prescrit",
          "answer": [
            {
              "valueString": "spironolactone 25mg",
              "item": [
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-atc",
                        "code": "C03DA01",
                        "display": "spironolactone"
                      }
                    }
                  ],
                  "linkId": "1923143398283",
                  "text": "codification"
                },
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-standardterms",
                        "code": "90001146",
                        "display": "Oral"
                      }
                    }
                  ],
                  "linkId": "387026794874",
                  "text": "Voie d'administration"
                }
              ]
            }
          ]
        },
        {
          "linkId": "6348237104421",
          "text": "Posologie (à détailler)",
          "item": [
            {
              "answer": [
                {
                  "valueDate": "2024-01-13"
                }
              ],
              "linkId": "316347573327",
              "text": "Date de début de la prescription"
            },
            {
              "answer": [
                {
                  "valueDate": "2024-02-13"
                }
              ],
              "linkId": "429570775935",
              "text": "Date de fin de la prescription"
            }
          ]
        },
        {
          "linkId": "266852453304",
          "text": "Médicament administré",
          "answer": [
            {
              "valueString": "spironolactone 25mg",
              "item": [
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-atc",
                        "code": "C03DA01",
                        "display": "spironolactone"
                      }
                    }
                  ],
                  "linkId": "631972144976",
                  "text": "codification"
                },
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-standardterms",
                        "code": "90001146",
                        "display": "Oral"
                      }
                    }
                  ],
                  "linkId": "811931484859",
                  "text": "Voie d'administration"
                }
              ]
            }
          ]
        },
        {
          "linkId": "5720103839343",
          "text": "Dosage",
          "item": [
            {
              "answer": [
                {
                  "valueQuantity": {
                    "value": 25,
                    "unit": "mg"
                  }
                }
              ],
              "linkId": "4765772671997",
              "text": "Quantité administrée"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-13T07:00:00.000Z"
                }
              ],
              "linkId": "1443558617577",
              "text": "Date et heure de début d'administration"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-13T07:05:00.000Z"
                }
              ],
              "linkId": "780829110731",
              "text": "Date et heure de fin d'administration"
            }
          ]
        },
        {
          "linkId": "5720103839343",
          "text": "Dosage",
          "item": [
            {
              "answer": [
                {
                  "valueQuantity": {
                    "value": 25,
                    "unit": "mg"
                  }
                }
              ],
              "linkId": "4765772671997",
              "text": "Quantité administrée"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-14T07:00:00.000Z"
                }
              ],
              "linkId": "1443558617577",
              "text": "Date et heure de début d'administration"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-14T07:05:00.000Z"
                }
              ],
              "linkId": "780829110731",
              "text": "Date et heure de fin d'administration"
            }
          ]
        }
      ]
    },
    {
      "linkId": "817801935685",
      "text": "Exposition médicamenteuse",
      "item": [
        {
          "linkId": "156631794800",
          "text": "Médicament prescrit",
          "answer": [
            {
              "valueString": "albumine 20%",
              "item": [
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-atc",
                        "code": "B05AA01",
                        "display": "albumine"
                      }
                    }
                  ],
                  "linkId": "1923143398283",
                  "text": "codification"
                },
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-standardterms",
                        "code": "90001141",
                        "display": "Intraveineux"
                      }
                    }
                  ],
                  "linkId": "387026794874",
                  "text": "Voie d'administration"
                }
              ]
            }
          ]
        },
        {
          "linkId": "6348237104421",
          "text": "Posologie (à détailler)",
          "item": [
            {
              "answer": [
                {
                  "valueDate": "2024-01-13"
                }
              ],
              "linkId": "316347573327",
              "text": "Date de début de la prescription"
            },
            {
              "answer": [
                {
                  "valueDate": "2024-01-13"
                }
              ],
              "linkId": "429570775935",
              "text": "Date de fin de la prescription"
            }
          ]
        },
        {
          "linkId": "266852453304",
          "text": "Médicament administré",
          "answer": [
            {
              "valueString": "albumine 20%",
              "item": [
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-atc",
                        "code": "B05AA01",
                        "display": "albumine"
                      }
                    }
                  ],
                  "linkId": "631972144976",
                  "text": "codification"
                },
                {
                  "answer": [
                    {
                      "valueCoding": {
                        "system": "https://smt.esante.gouv.fr/terminologie-standardterms",
                        "code": "90001141",
                        "display": "Intraveineux"
                      }
                    }
                  ],
                  "linkId": "811931484859",
                  "text": "Voie d'administration"
                }
              ]
            }
          ]
        },
        {
          "linkId": "5720103839343",
          "text": "Dosage",
          "item": [
            {
              "answer": [
                {
                  "valueQuantity": {
                    "value": 50,
                    "unit": "g"
                  }
                }
              ],
              "linkId": "4765772671997",
              "text": "Quantité administrée"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-13T08:30:00.000Z"
                }
              ],
              "linkId": "1443558617577",
              "text": "Date et heure de début d'administration"
            },
            {
              "answer": [
                {
                  "valueDateTime": "2024-01-13T10:14:00.000Z"
                }
              ],
              "linkId": "780829110731",
              "text": "Date et heure de fin d'administration"
            }
          ]
        }
      ]
    },
    {
      "linkId": "214880328197",
      "text": "Examen clinique",
      "item": [
        {
          "linkId": "305831246173",
          "text": "Dossier de soins",
          "item": [
            {
              "linkId": "4846902346416",
              "text": "Taille",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 162,
                    "unit": "cm"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueDate": "2024-01-13"
                        }
                      ],
                      "linkId": "941821315470",
                      "text": "Date de la mesure"
                    }
                  ]
                }
              ]
            },
            {
              "linkId": "451513217936",
              "text": "Poids",
              "answer": [
                {
                  "valueQuantity": {
                    "value": 58.2,
                    "unit": "kg"
                  },
                  "item": [
                    {
                      "answer": [
                        {
                          "valueDate": "2024-01-13"
                        }
                      ],
                      "linkId": "151269044052",
                      "text": "Date de la mesure"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ],
  "subject": {
    "display": "Mme Blanc"
  }
}
```

## MODÈLE du Questionnaire
```json
{
  "resourceType": "Questionnaire",
  "id": "UsageCore",
  "url": "https://interop.aphp.fr/ig/fhir/dm/Questionnaire/UsageCore",
  "name": "QuestionnaireUsageVariablesSoclesPourLesEDSH",
  "title": "Questionnaire usage Variables socles pour les EDSH",
  "status": "active",
  "date": "2025-02-03",
  "description": "Formalisation des variables du socle pour les EDSH",
  "item": [
    {
      "linkId": "4647259356106",
      "text": "Données socio-démographiques",
      "type": "group",
      "repeats": false,
      "item": [
        {
          "linkId": "2958000860428",
          "text": "Identité patient",
          "type": "group",
          "item": [
            {
              "linkId": "8605698058770",
              "text": "Nom patient",
              "type": "string"
            },
            {
              "linkId": "6214879623503",
              "text": "Prénom patient",
              "type": "string"
            },
            {
              "linkId": "5711960356160",
              "text": "Numéro d'inscription au Répertoire (NIR)",
              "type": "string",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "5711960356160_intention",
                  "text": "Numéro unique attribué à chaque personne à sa naissance sur la base d’éléments d’état civil transmis par les mairies à l’INSEE",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "3764723550987",
              "text": "Identité Nationale de Santé (INS)",
              "type": "string",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "3764723550987_intention",
                  "text": "Numéro d'identité unique, pérenne, partagée par l'ensemble des professionnels du monde de la santé",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "5036133558154",
              "text": "Date de naissance",
              "type": "date",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "5036133558154_intention",
                  "text": "Date de naissance des papiers d'identité utilisés pour la production de l'INS",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "5633552097315",
              "text": "Date de décès",
              "type": "date",
              "item": [
                {
                  "linkId": "9098810065693",
                  "text": "Source de la date de décès",
                  "type": "choice",
                  "answerOption": [
                    {
                      "valueCoding": {
                        "display": "INSEE"
                      }
                    },
                    {
                      "valueCoding": {
                        "display": "CepiDc"
                      }
                    },
                    {
                      "valueCoding": {
                        "display": "SIH"
                      }
                    }
                  ]
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "5633552097315_intention",
                  "text": "Date de décès à l'hopital, ou date de décès collectée par chaînage avec une base externe comme l'INSEE ou le CepiDc",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "6931296968515",
              "text": "Rang gémellaire du bénéficiaire",
              "type": "integer",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "6931296968515_intention",
                  "text": "Pour le régime général, il permet de distinguer les naissances gémellaires de même sexe",
                  "type": "display"
                }
              ]
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "2958000860428_intention",
              "text": "Identitologie. Clé d'appariement unique pouvant permettre le chaînage direct du socle avec d'autres bases",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "5491974639955",
          "text": "Environnement",
          "type": "group",
          "item": [
            {
              "linkId": "3816475533472",
              "text": "Géocodage",
              "type": "group",
              "repeats": true,
              "item": [
                {
                  "linkId": "3709843054556",
                  "text": "Latitude",
                  "type": "decimal"
                },
                {
                  "linkId": "7651448032665",
                  "text": "Longitude",
                  "type": "decimal"
                },
                {
                  "linkId": "1185653257776",
                  "text": "Date du recueil de l'information",
                  "type": "date"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "3816475533472_intention",
                  "text": "Coordonnées géographiques (latitude et longitude) de l'adresse du patient",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "7621032273792",
              "text": "IRIS",
              "type": "choice",
              "repeats": true,
              "answerOption": [
                {
                  "valueCoding": {
                    "system": "https://inse.fr/IRIS-cs",
                    "code": "010010000",
                    "display": "L'Abergement-Clémenciat (commune non irisée)"
                  }
                },
                {
                  "valueCoding": {
                    "system": "https://inse.fr/IRIS-cs",
                    "code": "010040102",
                    "display": "Longeray-Gare"
                  }
                },
                {
                  "valueCoding": {
                    "system": "https://inse.fr/IRIS-cs",
                    "code": "751151001",
                    "display": "GRENELLE"
                  }
                },
                {
                  "valueCoding": {
                    "system": "https://inse.fr/IRIS-cs",
                    "code": "765400102",
                    "display": "Vieux Marché Palais de Justice"
                  }
                },
                {
                  "valueCoding": {
                    "system": "https://inse.fr/IRIS-cs",
                    "code": "391900000",
                    "display": "Dampierre (commune non irisée)"
                  }
                }
              ],
              "item": [
                {
                  "linkId": "4999580038872",
                  "text": "Date du recueil de l'information",
                  "type": "date"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "7621032273792_intention",
                  "text": "Codage de l'adresse du patient selon la méthode d'Ilots Regroupés pour l'Information Statistique de l'INSEE. Si adresse géocodée non disponible",
                  "type": "display"
                }
              ]
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "5491974639955_intention",
              "text": "Clé d'appariement avec les bases de données environnementales. Données essentielles pour la conduite de recherches et d'études liées aux déterminants de santé",
              "type": "display"
            }
          ]
        }
      ]
    },
    {
      "linkId": "2825244231605",
      "text": "Données PMSI",
      "type": "group",
      "repeats": true,
      "item": [
        {
          "linkId": "8164976487070",
          "text": "Age",
          "type": "integer",
          "item": [
            {
              "linkId": "1690778867802",
              "text": "Date du recueil de l'information",
              "type": "date"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "8164976487070_intention",
              "text": "Age lors de la venue à l'hôpital tel que défini dans le PMSI. Si date de naissance (1.a.3) ou date de début du séjour (2.8) non disponibles",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "3894630481120",
          "text": "Sexe",
          "type": "choice",
          "answerOption": [
            {
              "valueCoding": {
                "system": "https://interop.aphp.fr/ig/fhir/dm/CodeSystem/DpiGender",
                "code": "h",
                "display": "Homme"
              }
            },
            {
              "valueCoding": {
                "system": "https://interop.aphp.fr/ig/fhir/dm/CodeSystem/DpiGender",
                "code": "f",
                "display": "Femme"
              }
            }
          ]
        },
        {
          "linkId": "2446369196222",
          "text": "Code géographique de résidence",
          "type": "choice",
          "answerOption": [
            {
              "valueCoding": {
                "system": "https://atih.sante.fr/CodesGeographiques-cs",
                "code": "04C01",
                "display": "LA CONDAMINE CHATELARD"
              }
            },
            {
              "valueCoding": {
                "system": "https://atih.sante.fr/CodesGeographiques-cs",
                "code": "01290",
                "display": "PONT DE VEYLE"
              }
            },
            {
              "valueCoding": {
                "system": "https://atih.sante.fr/CodesGeographiques-cs",
                "code": "75009",
                "display": "PARIS 9E ARRONDISSEMENT"
              }
            },
            {
              "valueCoding": {
                "system": "https://atih.sante.fr/CodesGeographiques-cs",
                "code": "75015",
                "display": "Paris 15ème arrondissement"
              }
            },
            {
              "valueCoding": {
                "system": "https://atih.sante.fr/CodesGeographiques-cs",
                "code": "76000",
                "display": "ROUEN"
              }
            },
            {
              "valueCoding": {
                "system": "https://atih.sante.fr/CodesGeographiques-cs",
                "code": "70180",
                "display": "DAMPIERRE SUR SALON"
              }
            }
          ],
          "item": [
            {
              "linkId": "1537511139540",
              "text": "Date du recueil de l'information",
              "type": "date"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "2446369196222_intention",
              "text": "Code de la commune de résidence du patient selon la classification PMSI",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "9391816419630",
          "text": "Diagnostics",
          "type": "group",
          "repeats": true,
          "item": [
            {
              "linkId": "7114466839467",
              "text": "Date du recueil de l'information",
              "type": "date"
            },
            {
              "linkId": "6427586743735",
              "text": "Type de diagnostic",
              "type": "choice",
              "answerOption": [
                {
                  "valueCoding": {
                    "display": "DP"
                  }
                },
                {
                  "valueCoding": {
                    "display": "DAS"
                  }
                },
                {
                  "valueCoding": {
                    "display": "DR"
                  }
                }
              ]
            },
            {
              "linkId": "5505101189372",
              "text": "Diagnostique",
              "type": "choice",
              "answerOption": [
                {
                  "valueCoding": {
                    "code": "I10",
                    "display": "Hypertension essentielle (primitive)"
                  }
                },
                {
                  "valueCoding": {
                    "code": "C01",
                    "display": "Tumeur maligne de la base de la langue"
                  }
                },
                {
                  "valueCoding": {
                    "code": "E11.9",
                    "display": "Diabète sucré de type 2, sans complication"
                  }
                },
                {
                  "valueCoding": {
                    "code": "N18.3",
                    "display": "Maladie rénale chronique, stade 3"
                  }
                },
                {
                  "valueCoding": {
                    "code": "K70.3",
                    "display": "Cirrhose alcoolique du foie"
                  }
                },
                {
                  "valueCoding": {
                    "code": "R18",
                    "display": "Ascite"
                  }
                },
                {
                  "valueCoding": {
                    "code": "E66.0",
                    "display": "Obésité due à un excès calorique"
                  }
                },
                {
                  "valueCoding": {
                    "code": "K20",
                    "display": "Œsophagite"
                  }
                }
              ],
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "5505101189372_intention",
                  "text": "quelques answerOption seulement du fait de l'absence de value set pertinent sur le SMT ou ailleurs...",
                  "type": "display"
                }
              ]
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "9391816419630_intention",
              "text": "L'ensemble des diagnostics (qu'il s'agisse de diagnostics principaux, diagnostics reliés, ou diagnostics associés significatifs) selon la classification CIM-10, à l'échelle du séjour",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "591926901726",
          "text": "Actes",
          "type": "group",
          "repeats": true,
          "item": [
            {
              "linkId": "9436509453137",
              "text": "Date du recueil de l'information",
              "type": "date"
            },
            {
              "linkId": "5066866286682",
              "text": "Date de l'acte",
              "type": "dateTime"
            },
            {
              "linkId": "7758110033600",
              "text": "Acte",
              "type": "choice",
              "answerValueSet": "https://interop.aphp.fr/ig/fhir/dm/ValueSet/Ccam",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "7758110033600_intention",
                  "text": "C'est une CCAM exemple de l'IG",
                  "type": "display"
                }
              ]
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "591926901726_intention",
              "text": "Ensemble des actes médicotechniques réalisés par les médecins, selon la classification utilisée dans chaque PMSI",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "5991443718282",
          "text": "Date de début de séjour",
          "type": "date",
          "item": [
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "5991443718282_intention",
              "text": "Date de début du séjour",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "6114780320846",
          "text": "Date de fin de séjour",
          "type": "date",
          "item": [
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "6114780320846_intention",
              "text": "Date de fin du séjour",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "6172398101212",
          "text": "Mode d'entrée du séjour",
          "type": "choice",
          "answerOption": [
            {
              "valueCoding": {
                "code": "6",
                "display": "Mutation"
              }
            },
            {
              "valueCoding": {
                "code": "7",
                "display": "Transfert définitif"
              }
            },
            {
              "valueCoding": {
                "code": "0",
                "display": "Transfert provisoire"
              }
            },
            {
              "valueCoding": {
                "code": "8",
                "display": "Domicile"
              }
            },
            {
              "valueCoding": {
                "code": "N",
                "display": "Naissance"
              }
            },
            {
              "valueCoding": {
                "code": "O",
                "display": "Patient entré décédé pour prélèvement d'organes"
              }
            }
          ],
          "item": [
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "6172398101212_intention",
              "text": "Mode d'entrée pendant le séjour ; dans le cas d'un séjour avec passage dans plusieurs unités médicales, il s'agit du mode d'entrée dans la première unité médicale dans l’ordre chronologique pendant le séjour",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "3354867075704",
          "text": "Mode de sortie du séjour",
          "type": "choice",
          "answerOption": [
            {
              "valueCoding": {
                "code": "6",
                "display": "Mutation"
              }
            },
            {
              "valueCoding": {
                "code": "7",
                "display": "Transfert définitif"
              }
            },
            {
              "valueCoding": {
                "code": "0",
                "display": "Transfert provisoire"
              }
            },
            {
              "valueCoding": {
                "code": "8",
                "display": "Domicile"
              }
            },
            {
              "valueCoding": {
                "code": "9",
                "display": "Décès"
              }
            }
          ],
          "item": [
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "3354867075704_intention",
              "text": "Mode de sortie pendant le séjour ; dans le cas d'un séjour avec passage dans plusieurs unités médicales, il s'agit du mode de sortie de la dernière unité médicale dans l’ordre chronologique pendant le séjour",
              "type": "display"
            }
          ]
        },
        {
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "help",
                    "display": "Help-Button"
                  }
                ],
                "text": "Intention"
              }
            }
          ],
          "linkId": "2825244231605_intention",
          "text": "Description générale du patient et de la venue à l'hôpital,dans les différents PMSI (MCO, SSR, HAD, Psy)",
          "type": "display"
        }
      ]
    },
    {
      "linkId": "7702944131447",
      "text": "Biologie",
      "type": "group",
      "repeats": false,
      "item": [
        {
          "linkId": "5241323453538",
          "text": "Fonction rénale",
          "type": "group",
          "repeats": false,
          "item": [
            {
              "linkId": "7169026818760",
              "text": "Dosage de l'urée dans le sang",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "8712072639576",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "554606544143",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "5827729311488",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "3753371809615",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "7284688712273",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "7169026818760_intention",
                  "text": "Dosage sanguin de l'urée qui permet d'évaluer la fonction rénale",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "500408205043",
              "text": "Créatininémie",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "977768150991",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "279176538278",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "271848662924",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "488869963230",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "984480974142",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "272068880657",
                  "text": "Dosage sanguin de la créatinine qui permet d'évaluer la fonction rénale",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "786621340679",
              "text": "Débit de filtration glomérulaire (DFG)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "974417569313",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "600008092136",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "288013601711",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "809916645548",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "323493215684",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "195685944623",
                  "text": "Le débit de filtration par les glomérules rénaux permet d'évaluer la fonction rénale en dehors des épisodes aigus",
                  "type": "display"
                }
              ]
            }
          ]
        },
        {
          "linkId": "419282985970",
          "text": "Hémogramme",
          "type": "group",
          "repeats": false,
          "item": [
            {
              "linkId": "210077225604",
              "text": "Leucocytes",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "695484403752",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "578695171519",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "844270911527",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "147832677057",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "175377691907",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "382375729527",
                  "text": "Dosage sanguin des globules blancs",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "304159088493",
              "text": "Hémoglobine",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "597082091886",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "471894150678",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "958333284757",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "404489113722",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "849522090945",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "420718626675",
                  "text": "Dosage sanguin de l'hémoglobine permettant le diagnostic de l'anémie",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "813863316705",
              "text": "Hématocrite",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "814457693114",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "717817548701",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "379339292477",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "728299430368",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "296878978572",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "826231994103",
                  "text": "Volume occupé par les globules rouges dans le sang, par rapport au volume sanguin total. Utile pour évaluer l'état d'hydratation du patient et poser de nombreux diagnostics",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "459731866614",
              "text": "Globules rouges",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "274747215145",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "394008758803",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "536131874715",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "823112437353",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "567971363132",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "332414288877",
                  "text": "Dosage sanguin des globules rouges",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "163624088831",
              "text": "Volume Globulaire Moyen (VGM)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "117718572179",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "766800452654",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "490513081670",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "472419988966",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "781499407274",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "258348056463",
                  "text": "Volume moyen des globules rouges, qui est une valeur centrale pour le diagnostic des anémies",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "794156787471",
              "text": "Plaquettes",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "555876654291",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "504411027287",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "639812945465",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "491138393211",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "859081902103",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "466904505570",
                  "text": "Dosage sanguin des plaquettes, utile pour toute pathologie faisant intervenir le système immunitaire / hématologique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "961905168477",
              "text": "Neutrophiles",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "971737782589",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "255457777106",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "473989322417",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "501223312827",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "454392779990",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "664900547119",
                  "text": "Dosage sanguin des globules blancs de type polynucléaires neutrophiles, utile pour toute pathologie faisant intervenir le système immunitaire / hématologique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "695150914696",
              "text": "Lymphocytes",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "663015267867",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "548571990081",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "357661538905",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "217415906562",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "719012554421",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "613857432608",
                  "text": "Dosage sanguin des globules blancs de type lymphocytes, utile pour toute pathologie faisant intervenir le système immunitaire / hématologique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "700490326748",
              "text": "Eosinophiles",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "283372872777",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "732609383475",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "427000822533",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "162927062211",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "801523695037",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "607091164403",
                  "text": "Dosage sanguin des globules blancs de type éosinophiles, utile pour toute pathologie faisant intervenir le système immunitaire  / hématologique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "168661900522",
              "text": "Monocytes",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "651849853076",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "773480648641",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "335226309641",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "693935514182",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "241118076478",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "757972628934",
                  "text": "Dosage sanguin des globules blancs de type monocytes, utile pour toute pathologie faisant intervenir le système immunitaire / hématologique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "658898841893",
              "text": "Taux de prothrombine (TP)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "219513623269",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "379165914699",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "429387291763",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "253311419093",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "706043904552",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "772627508475",
                  "text": "Le taux de prothrombine permet d'évaluer la coagulation du sang",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "795145096241",
              "text": "Temps de céphaline activée (TCA)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "664804454505",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "339688288601",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "754581131140",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "680824187549",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "293820463780",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "391959403634",
                  "text": "Le temps de céphaline activée permet d'évaluer la coagulation du sang",
                  "type": "display"
                }
              ]
            }
          ]
        },
        {
          "linkId": "796308115381",
          "text": "Bilan hépatique",
          "type": "group",
          "repeats": false,
          "item": [
            {
              "linkId": "715226319725",
              "text": "Aspartate aminotransférase (AST)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "757363598159",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "884511824515",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "899626356193",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "584123691679",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "935082505777",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "155300271843",
                  "text": "Dosage sanguin d'une enzyme permettant d'évaluer la fonction hépatique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "876439410327",
              "text": "Alanine aminotransférase (ALT)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "698926487710",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "881040341675",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "914082125507",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "581883215378",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "594636277238",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "805019270382",
                  "text": "Dosage sanguin d'une enzyme permettant d'évaluer la fonction hépatique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "287545455976",
              "text": "Gamma-glutamyl transférase (GGT)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "688754894578",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "191793018592",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "554823851678",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "529114499294",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "930639734905",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "455354251362",
                  "text": "Dosage sanguin d'une enzyme permettant d'évaluer la fonction hépatique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "508269571594",
              "text": "Phosphatases alcalines (PAL)",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "726897332003",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "576101241859",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "650432942630",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "334934131934",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "989367019315",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "977709314949",
                  "text": "Dosage sanguin d'une enzyme permettant d'évaluer la fonction hépatique ou certaines maladies osseuses ou métaboliques",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "927344090061",
              "text": "Bilirubine totale",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "657001208566",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "943765996333",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "510595115954",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "439478297194",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "363409811810",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "783113311620",
                  "text": "Dosage sanguin de la bilirubine, produit de dégradation de l'hémoglobine, permettant d'évaluer la fonction hépatique",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "208196328453",
              "text": "Bilirubine conjuguée",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "572609665342",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "481261763129",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "711131346437",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "454797820953",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "741523817402",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "321386539842",
                  "text": "Dosage sanguin de la bilirubine conjuguée, produit de dégradation de l'hémoglobine, permettant d'évaluer la fonction hépatique",
                  "type": "display"
                }
              ]
            }
          ]
        },
        {
          "linkId": "334039497382",
          "text": "Autres",
          "type": "group",
          "repeats": false,
          "item": [
            {
              "linkId": "273778921448",
              "text": "Glycémie à jeun",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "398039571990",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "632111374848",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "844988086697",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "228927847562",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "269189312131",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "977261815970",
                  "text": "Dosage sanguin pour diagnostic du diabète",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "632894677152",
              "text": "Hémoglobine glyquée",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "305948197507",
                  "text": "code loinc",
                  "type": "choice",
                  "answerValueSet": "http://hl7.org/fhir/ValueSet/observation-codes"
                },
                {
                  "linkId": "249760336391",
                  "text": "Date et heure du prélèvement",
                  "type": "dateTime"
                },
                {
                  "linkId": "255050517895",
                  "text": "Statut de validation",
                  "type": "string"
                },
                {
                  "linkId": "804046966782",
                  "text": "Borne inférieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "linkId": "703927692674",
                  "text": "Borne supérieure de normalité du résultat",
                  "type": "quantity"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "138957204850",
                  "text": "Dosage sanguin de l'hémoglobine glyquée, qui est la part de l'hémoglobine qui capte le sucre dans le sang et est un reflet cumulé de la glycémie sur les derniers mois. Permet le diagnostic et le suivi du diabète",
                  "type": "display"
                }
              ]
            }
          ]
        },
        {
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "help",
                    "display": "Help-Button"
                  }
                ],
                "text": "Intention"
              }
            }
          ],
          "linkId": "7702944131447_intention",
          "text": "Les données de biologie contribuent au diagnostic, à l’évaluation de la sévérité, de la tolérance des produits de santé, au suivi des patients, etc., et constituent en tant que tels des indicateurs d’intérêt scientifique  Données cliniques non disponibles dans la base principale du SNDS  Les variables de biologie proposées constituent un socle minimal pour fournir une vision de l'état général du patient",
          "type": "display"
        }
      ]
    },
    {
      "linkId": "817801935685",
      "text": "Exposition médicamenteuse",
      "type": "group",
      "repeats": true,
      "item": [
        {
          "linkId": "156631794800",
          "text": "Médicament prescrit",
          "type": "string",
          "repeats": true,
          "item": [
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-preferredTerminologyServer",
                  "valueUrl": "https://smt.esante.gouv.fr/fhir"
                }
              ],
              "linkId": "1923143398283",
              "text": "codification",
              "type": "choice",
              "repeats": true,
              "answerValueSet": "https://smt.esante.gouv.fr/terminologie-atc?vs"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-preferredTerminologyServer",
                  "valueUrl": "https://smt.esante.gouv.fr/fhir"
                }
              ],
              "linkId": "387026794874",
              "text": "Voie d'administration",
              "type": "choice",
              "repeats": false,
              "answerValueSet": "https://smt.esante.gouv.fr/terminologie-standardterms?vs"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "156631794800_intention",
              "text": "Libellé du médicament prescrit",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "6348237104421",
          "text": "Posologie (à détailler)",
          "type": "group",
          "repeats": false,
          "item": [
            {
              "linkId": "316347573327",
              "text": "Date de début de la prescription",
              "type": "date",
              "repeats": false
            },
            {
              "linkId": "429570775935",
              "text": "Date de fin de la prescription",
              "type": "date",
              "repeats": false
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "6348237104421_intention",
              "text": "Posologie quantitative de la prescription. Métadonnées en cours de définition par l'ANS (livraison fin 2023)",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "266852453304",
          "text": "Médicament administré",
          "type": "string",
          "repeats": true,
          "item": [
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-preferredTerminologyServer",
                  "valueUrl": "https://smt.esante.gouv.fr/fhir"
                }
              ],
              "linkId": "631972144976",
              "text": "codification",
              "type": "choice",
              "repeats": true,
              "answerValueSet": "https://smt.esante.gouv.fr/terminologie-atc?vs"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-preferredTerminologyServer",
                  "valueUrl": "https://smt.esante.gouv.fr/fhir"
                }
              ],
              "linkId": "811931484859",
              "text": "Voie d'administration",
              "type": "choice",
              "repeats": false,
              "answerValueSet": "https://smt.esante.gouv.fr/terminologie-standardterms?vs"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "380392928278",
              "text": "Libellé du médicament administré",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "5720103839343",
          "text": "Dosage",
          "type": "group",
          "repeats": true,
          "item": [
            {
              "linkId": "4765772671997",
              "text": "Quantité administrée",
              "type": "quantity",
              "repeats": false
            },
            {
              "linkId": "1443558617577",
              "text": "Date et heure de début d'administration",
              "type": "dateTime",
              "repeats": false
            },
            {
              "linkId": "780829110731",
              "text": "Date et heure de fin d'administration",
              "type": "dateTime",
              "repeats": false
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "5720103839343_intention",
              "text": "Dosage du médicament administré par prise",
              "type": "display"
            }
          ]
        },
        {
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "help",
                    "display": "Help-Button"
                  }
                ],
                "text": "Intention"
              }
            }
          ],
          "linkId": "817801935685_intention",
          "text": "L'exposition médicamenteuse est essentielle pour la caractérisation et l’étude des pathologies médicales et de leurs facteurs de risque, l’évaluation et l’amélioration de leur prise en charge, ainsi que pour les études (notamment de pharmacovigilance) en vie réelle.  Données cliniques non disponibles dans la base principale du SNDS",
          "type": "display"
        }
      ]
    },
    {
      "linkId": "214880328197",
      "text": "Examen clinique",
      "type": "group",
      "item": [
        {
          "linkId": "305831246173",
          "text": "Dossier de soins",
          "type": "group",
          "repeats": true,
          "item": [
            {
              "linkId": "4846902346416",
              "text": "Taille",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "941821315470",
                  "text": "Date de la mesure",
                  "type": "date"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "4846902346416_intention",
                  "text": "Taille du patient telle que relevée à un instant donné lors de sa venue à l'hôpital",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "451513217936",
              "text": "Poids",
              "type": "quantity",
              "repeats": true,
              "item": [
                {
                  "linkId": "151269044052",
                  "text": "Date de la mesure",
                  "type": "date"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "451513217936_intention",
                  "text": "Poids du patient tel que relevé à un instant donné lors de sa venue à l'hôpital",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "4160905247955",
              "text": "Pression artérielle systolique",
              "type": "quantity",
              "item": [
                {
                  "linkId": "987654638442",
                  "text": "Date de la mesure",
                  "type": "date"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "4160905247955_intention",
                  "text": "Pression artérielle systolique mesurée à un instant donné de la venue du patient à l'hôpital",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "848797127998",
              "text": "Pression artérielle diastolique",
              "type": "quantity",
              "item": [
                {
                  "linkId": "820981783585",
                  "text": "Date de la mesure",
                  "type": "date"
                },
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "848797127998_intention",
                  "text": "Pression artérielle diastolique mesurée à un instant donné de la venue du patient à l'hôpital",
                  "type": "display"
                }
              ]
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "http://hl7.org/fhir/questionnaire-item-control",
                        "code": "help",
                        "display": "Help-Button"
                      }
                    ],
                    "text": "Intention"
                  }
                }
              ],
              "linkId": "305831246173_intention",
              "text": "Caractérisation générale du patient et facteurs de risque. Données cliniques non disponibles dans la base principale du SNDS",
              "type": "display"
            }
          ]
        },
        {
          "linkId": "1693164086678",
          "text": "Style de vie",
          "type": "group",
          "repeats": true,
          "item": [
            {
              "linkId": "6516656388671",
              "text": "Consommation de tabac (A définir dans des travaux complémentaires)",
              "type": "group",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "6516656388671_intention",
                  "text": "Consommation de tabac par le patient.",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "8218964737490",
              "text": "Consommation d'alcool (A définir dans des travaux complémentaires)",
              "type": "group",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "8218964737490_intention",
                  "text": "Consommation d'alcool par le patient.",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "7063448155344",
              "text": "Consommation d'autres drogues (A définir dans des travaux complémentaires)",
              "type": "group",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "7063448155344_intention",
                  "text": "Nom des autres drogues consommées régulièrement le cas échéant",
                  "type": "display"
                }
              ]
            },
            {
              "linkId": "485428113240",
              "text": "Activité physique (A définir dans des travaux complémentaires)",
              "type": "group",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "485428113240_intention",
                  "text": "Activité physique du patient",
                  "type": "display"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## DONNÉES DES PATIENTS

Les données des exemples se trouve `data-platform/raw-layer/test/file/*.csv`

## INSTRUCTIONS STRICTES

1. Générer UNIQUEMENT la ressource QuestionnaireResponse pour le patient numéro **{N}**
2. Respecter strictement le format FHIR (JSON valide)
3. Mapper TOUTES les données disponibles du patient dans les items appropriés
4. Respecter la ressource Questionnaire disponible dans la section **MODÈLE du Questionnaire**
5. Assurer la cohérence des dates et références
6. Ne PAS ajouter l'élement `subject`
7. Utiliser les linkId de la ressource Questionnaire et seulement (pas de nouveau linkid)
8. Pour les réponses codées, utiliser strictement les choix possible issue du Questionnaire et ne pas mettre les display
9. Générer les items que si il y a des réponses, pas de tableau vide
10. Prendre les systèmes de codage définis dans la ressource Questionnaire (suivre l'exemple)
11. Les actes doivent provenir du système de codage : https://smt.esante.gouv.fr/terminologie-ccam (suivre l'exemple)
12. Les médicament doivent provenir du système de codage : https://smt.esante.gouv.fr/terminologie-atc (suivre l'exemple)
13. Les voies d'administration doivent provenir du système de codage : https://smt.esante.gouv.fr/terminologie-standardterms (suivre l'exemple)
14. Le résutlat doit se trouver dans `input/resources/usages/core/`
15. Le nom du fichier doit être `QuestionnaireResponse-cas-NUMERO-usage-core.json` NUMERO étant le numéro patient
16. Ne PAS générer d'autres ressources QuestionnaireResponse

## COMMANDE

Génère la ressource FHIR QuestionnaireResponse uniquement pour le patient numéro **4**

## FORMAT DE SORTIE

JSON uniquement, valide FHIR, sans commentaires.

## Vérifications

- Tous les item.linkId de la ressource QuestionnareResponse générée doivent être présent dans la ressource Questionnaire `input/resources/usages/core/Questionnaire-UsageCore.json`
- Tous les item.text de la ressource QuestionnareResponse générée doivent être identique dans la ressource Questionnaire `input/resources/usages/core/Questionnaire-UsageCore.json`
- Tous les item.answer valeur de type valueCoding doivent tenir compte de la listes des réponses possibles définis dnas la ressource Questionnaire `input/resources/usages/core/Questionnaire-UsageCore.json`
