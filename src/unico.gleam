import gleam/io
import gleam/list
import gleam/string
import gleam/option.{type Option, None, Some}

// 
// menus.gleam
//
pub type MainMenu {
  Explorar
  Inventario
  Pistas
  Mover(destino: String)
  Interagir(nome_obj: String)
  Sair
}

// Resultado de uma opcao do menu
pub type ResultadoMenu {
  Mostrar(mensagem: String)
  Encerrar
}

// Apresenta o menu
pub fn display_main_menu() {
  io.println("\n--- MENU PRINCIPAL ---")
  io.println("m1(): Explorar ambiente")
  io.println("m2(): Consultar inventário")
  io.println("m3(): Consultar pistas")
  io.println("m4(destino): Mover para outro ambiente")
  io.println("m5(objeto): Interagir com objeto")
  io.println("exit(): Encerrar simulação")
}

// Seleciona as opcoes
pub fn m1() -> MainMenu {
  Explorar
}

pub fn m2() -> MainMenu {
  Inventario
}

pub fn m3() -> MainMenu {
  Pistas
}

pub fn m4(destino: String) -> MainMenu {
  Mover(destino)
}

pub fn m5(nome_obj: String) -> MainMenu {
  Interagir(nome_obj)
}

pub fn exit() -> MainMenu {
  Sair
}

pub fn executar_opcao(
  estado: Jogo,
  opcao: MainMenu,
) -> Result(#(Jogo, ResultadoMenu), ErroJogo) {
  case estado.situacao {
    Vitoria ->
      case opcao {
        Sair -> Ok(#(estado, Encerrar))
        _ -> Error(JogoEncerrado)
      }

    Derrota ->
      case opcao {
        Sair -> Ok(#(estado, Encerrar))
        _ -> Error(JogoEncerrado)
      }

    EmAndamento ->
      executar_opcao_em_andamento(estado, opcao)
  }
}

// Executa a opção escolhida
pub fn executar_opcao_em_andamento(
  estado: Jogo,
  opcao: MainMenu,
) -> Result(#(Jogo, ResultadoMenu), ErroJogo) {
  case opcao {
    Explorar -> {
      case explorar_atual(estado) {
        Ok(texto) -> Ok(#(estado, Mostrar(texto)))
        Error(erro) -> Error(erro)
      }
    }

    Inventario -> {
      let itens = estado.jogador.inventario

      let texto = case itens {
        [] -> "Inventario vazio."
        _ -> "Inventario: " <> string.join(itens, ", ")
      }

      Ok(#(estado, Mostrar(texto)))
    }

    Pistas -> {
      let pistas = estado.jogador.pistas

      let texto = case pistas {
        [] -> "Nenhuma pista."
        _ -> "Pistas: " <> string.join(pistas, ", ")
      }

      Ok(#(estado, Mostrar(texto)))
    }

    Mover(destino) -> {
      case mover_jogador(estado, destino) {
        Ok(novo_jogo) -> {
          let mensagem = case novo_jogo.jogador.local == destino {
            True ->
              "Voce se deslocou para " <> destino <> "."

            False ->
              "O ambiente esta bloqueado! Voce nao conseguiu entrar."
          }

          finalizar_acao(novo_jogo, mensagem)
        }

        Error(erro) -> Error(erro)
      }
    }

    Interagir(nome_obj) -> {
      case interagir_objeto(estado, nome_obj) {
        Error(erro) -> Error(erro)

        Ok(#(novo_jogo, resultado)) -> {
          let mensagem = descrever_resultado_interacao(resultado)

          finalizar_acao(novo_jogo, mensagem)
        }
      }
    }

    Sair -> Ok(#(estado, Encerrar))
  }
}

pub fn descrever_erro(erro: ErroJogo) -> String {
  case erro {
    JogoEncerrado ->
      "A simulacao ja foi encerrada."

    FaseNaoEncontrada ->
      "A fase atual nao foi encontrada."

    FaseNaoConcluida ->
      "Voce ainda nao concluiu esta fase."

    AmbienteNaoEncontrado ->
      "Este ambiente nao existe."

    AmbienteInacessivel ->
      "Este ambiente esta bloqueado."

    SaidaNaoConectada ->
      "Nao existe uma passagem direta para esse ambiente."

    ObjetoNaoEncontrado ->
      "Este objeto nao foi encontrado aqui."

    ObjetoIndisponivel ->
      "Este objeto nao pode mais ser utilizado."

    FerramentaAusente(_) ->
      "Esta faltando algo para realizar essa acao."

    AmbienteInicialInvalido ->
      "O ambiente inicial da proxima fase esta indisponivel."
  }
}

pub fn descrever_resultado_interacao(
  resultado: ResultadoInteracao,
) -> String {
  case resultado {
    InteracaoConcluida ->
      "Voce realizou a interacao com sucesso."

    InteracaoSemEfeito(motivo) ->
      motivo

    InteracaoComErro(erro) ->
      descrever_erro(erro)
  }
}

fn finalizar_acao(
  jogo: Jogo,
  mensagem: String,
) -> Result(#(Jogo, ResultadoMenu), ErroJogo) {
  case jogo.situacao {
    Derrota ->
      Ok(#(
        jogo,
        Mostrar("O tempo acabou! Voce perdeu o jogo."),
      ))

    Vitoria ->
      Ok(#(
        jogo,
        Mostrar("Parabens! Voce venceu o jogo!"),
      ))

    EmAndamento -> {
      case verificar_progresso(jogo) {
        Error(erro) -> Error(erro)

        Ok(#(novo_jogo, None)) ->
          Ok(#(novo_jogo, Mostrar(mensagem)))

        Ok(#(novo_jogo, Some(mensagem_progresso))) ->
          Ok(#(
            novo_jogo,
            Mostrar(mensagem <> "\n" <> mensagem_progresso),
          ))
      }
    }
  }
}

// 
// jogo.gleam
// 
pub type Jogo {
  Jogo(
    jogador: Jogador,
    fases: List(Fase),
    fase_atual: Int,
    situacao: SituacaoJogo,
  )
}

pub type SituacaoJogo {
  EmAndamento
  Vitoria
  Derrota
}

pub type ErroJogo {
  JogoEncerrado
  FaseNaoEncontrada
  FaseNaoConcluida
  AmbienteNaoEncontrado
  AmbienteInacessivel
  SaidaNaoConectada
  ObjetoNaoEncontrado
  ObjetoIndisponivel
  FerramentaAusente(nome: String)
  AmbienteInicialInvalido
}

pub type ResultadoInteracao {
  InteracaoConcluida
  InteracaoSemEfeito(motivo: String)
  InteracaoComErro(erro: ErroJogo)
}

fn finalizar_interacao(
  resultado: Result(Jogo, ErroJogo),
) -> Result(#(Jogo, ResultadoInteracao), ErroJogo) {
  case resultado {
    Ok(novo_jogo) ->
      Ok(#(novo_jogo, InteracaoConcluida))

    Error(erro) ->
      Error(erro)
  }
}

// Mostra as informacoes do Ambiente onde esta o jogador
pub fn explorar_atual(jogo: Jogo) -> Result(String, ErroJogo) {
  case obter_ambiente_atual(jogo) {
    Error(erro) -> Error(erro)

    Ok(ambiente) -> {
      case ambiente.acessivel {
        True -> Ok(explorar_ambiente(ambiente))
        False -> Error(AmbienteInacessivel)
      }
    }
  }
}

// Define uma nova *situ* pro *jogo*
pub fn altera_situacao(jogo: Jogo, situ: SituacaoJogo) -> Jogo {
  Jogo(..jogo, situacao: situ)
}

// Retorna se um *jogo* ja acabou ou não
pub fn jogo_finalizado(jogo: Jogo) -> Bool {
  case jogo.situacao {
    EmAndamento -> False
    _ -> True
  }
}

pub fn obter_fase_atual(jogo: Jogo) -> Result(Fase, ErroJogo) {
  case buscar_fase_lista(jogo.fases, jogo.fase_atual) {
    Ok(fase) -> Ok(fase)
    Error(Nil) -> Error(FaseNaoEncontrada)
  }
}

pub fn obter_ambiente_atual(jogo: Jogo) -> Result(Ambiente, ErroJogo) {
  case obter_fase_atual(jogo) {
    Error(erro) -> Error(erro)

    Ok(fase) -> {
      case buscar_ambiente(fase, jogo.jogador.local) {
        Ok(ambiente) -> Ok(ambiente)
        Error(Nil) -> Error(AmbienteNaoEncontrado)
      }
    }
  }
}

fn buscar_fase_lista(
  fases: List(Fase),
  id: Int,
) -> Result(Fase, Nil) {
  case fases {
    [] -> Error(Nil)
    [prim, ..resto] ->
      case prim.id == id {
        True -> Ok(prim)
        False -> buscar_fase_lista(resto, id)
      }
  }
}

pub fn mover_jogador(
  jogo: Jogo,
  destino: String,
) -> Result(Jogo, ErroJogo) {
  case jogo.situacao {
    Vitoria -> Error(JogoEncerrado)
    Derrota -> Error(JogoEncerrado)

    EmAndamento -> {
      case obter_fase_atual(jogo) {
        Error(erro) -> Error(erro)

        Ok(fase) -> {
          case obter_ambiente_atual(jogo) {
            Error(erro) -> Error(erro)

            Ok(ambiente_atual) -> {
              case contem_nome(ambiente_atual.saidas, destino) {
                False -> Error(SaidaNaoConectada)

                True -> {
                  case buscar_ambiente(fase, destino) {
                    Error(Nil) -> Error(AmbienteNaoEncontrado)

                    Ok(ambiente_destino) -> {
                      case ambiente_destino.acessivel {
                        False -> registrar_acao(jogo)

                        True -> {
                          let jogador_atualizado =
                            mudar_local(jogo.jogador, destino)

                          let jogo_atualizado = Jogo(
                            ..jogo,
                            jogador: jogador_atualizado,
                          )

                          registrar_acao(jogo_atualizado)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn contem_nome(lista: List(String), nome: String) -> Bool {
  case lista {
    [] -> False
    [prim, ..resto] ->
      case prim == nome {
        True -> True
        False -> contem_nome(resto, nome)
      }
  }
}

fn salvar_fase_no_jogo(jogo: Jogo, nova_fase: Fase) -> Jogo {
  let novas_fases = list.map(
    jogo.fases,
    fn(fase) {
      case fase.id == nova_fase.id {
        True -> nova_fase
        False -> fase
      }
    },
  )

  Jogo(..jogo, fases: novas_fases)
}

fn salvar_interacao(
  jogo: Jogo,
  fase_atual: Fase,
  ambiente_atual: Ambiente,
  novo_objeto: Objeto,
  novo_jogador: Jogador,
  ambiente_desbloquear: Option(String),
) -> Result(Jogo, ErroJogo) {
  case atualizar_objeto(ambiente_atual, novo_objeto) {
    Error(Nil) -> Error(ObjetoNaoEncontrado)

    Ok(novo_ambiente) -> {
      case atualizar_ambiente(fase_atual, novo_ambiente) {
        Error(Nil) -> Error(AmbienteNaoEncontrado)

        Ok(nova_fase) -> {
          let jogo_atualizado =
            salvar_fase_no_jogo(jogo, nova_fase)

          let jogo_atualizado = Jogo(
            ..jogo_atualizado,
            jogador: novo_jogador,
          )

          let jogo_atualizado = case ambiente_desbloquear {
            None -> Ok(jogo_atualizado)

            Some(nome) ->
              alterar_acessibilidade(
                jogo_atualizado,
                nome,
                True,
              )
          }

          case jogo_atualizado {
            Error(erro) -> Error(erro)
            Ok(novo_jogo) -> registrar_acao(novo_jogo)
          }
        }
      }
    }
  }
}


pub fn interagir_objeto(
  jogo: Jogo,
  nome_obj: String,
) -> Result(#(Jogo, ResultadoInteracao), ErroJogo) {
  case jogo.situacao {
    Vitoria -> Error(JogoEncerrado)
    Derrota -> Error(JogoEncerrado)

    EmAndamento -> {
      case obter_fase_atual(jogo) {
        Error(erro) -> Error(erro)

        Ok(fase_atual) -> {
          case buscar_ambiente(fase_atual, jogo.jogador.local) {
            Error(Nil) -> Error(AmbienteNaoEncontrado)

            Ok(ambiente_atual) -> {
              case buscar_objeto(ambiente_atual, nome_obj) {
                Error(Nil) -> Error(ObjetoNaoEncontrado)

                Ok(obj) -> {
                  case ambiente_atual.acessivel {
                    False -> Error(AmbienteInacessivel)

                    True ->
                      case obj.estado {
                        Coletavel -> {
                          let novo_jogador =
                            objeto.interagir(obj, jogo.jogador)

                          let novo_objeto =
                            objeto.atualizar_estado(obj, Coletado)

                          finalizar_interacao(
                            salvar_interacao(
                              jogo,
                              fase_atual,
                              ambiente_atual,
                              novo_objeto,
                              novo_jogador,
                              None,
                            ),
                          )
                        }

                        Disponivel -> {
                          let novo_jogador =
                            objeto.interagir(obj, jogo.jogador)

                          let novo_objeto =
                            objeto.atualizar_estado(obj, Indisponivel)

                          finalizar_interacao(
                            salvar_interacao(
                              jogo,
                              fase_atual,
                              ambiente_atual,
                              novo_objeto,
                              novo_jogador,
                              None,
                            ),
                          )
                        }

                        Quebrado(ferramenta, _) -> {
                          case jogador.possui_obj(
                            jogo.jogador,
                            ferramenta,
                          ) {
                            False ->
                              registrar_falha_interacao(
                                jogo,
                                FerramentaAusente(ferramenta),
                              )

                            True -> {
                              let novo_objeto =
                                objeto.consertar(obj, jogo.jogador)

                              finalizar_interacao(
                                salvar_interacao(
                                  jogo,
                                  fase_atual,
                                  ambiente_atual,
                                  novo_objeto,
                                  jogo.jogador,
                                  None,
                                ),
                              )
                            }
                          }
                        }

                        RequerItem(item, novo_estado) -> {
                          case jogador.possui_obj(
                            jogo.jogador,
                            item,
                          ) {
                            False ->
                              registrar_falha_interacao(
                                jogo,
                                FerramentaAusente(item),
                              )

                            True -> {
                              let novo_jogador =
                                objeto.interagir(obj, jogo.jogador)

                              let novo_objeto =
                                objeto.atualizar_estado(
                                  obj,
                                  novo_estado,
                                )

                              finalizar_interacao(
                                salvar_interacao(
                                  jogo,
                                  fase_atual,
                                  ambiente_atual,
                                  novo_objeto,
                                  novo_jogador,
                                  None,
                                ),
                              )
                            }
                          }
                        }
                        DesbloqueiaAmbiente(item, ambiente, novo_estado) -> {
                          case jogador.possui_obj(jogo.jogador, item) {
                            False ->
                              registrar_falha_interacao(
                                jogo,
                                FerramentaAusente(item),
                              )

                            True -> {
                              let novo_jogador =
                                objeto.interagir(obj, jogo.jogador)

                              let novo_objeto =
                                objeto.atualizar_estado(obj, novo_estado)

                              finalizar_interacao(
                                salvar_interacao(
                                  jogo,
                                  fase_atual,
                                  ambiente_atual,
                                  novo_objeto,
                                  novo_jogador,
                                  Some(ambiente),
                                ),
                              )
                            }
                          }
                        }

                        Indisponivel -> Error(ObjetoIndisponivel)
                        Coletado -> Error(ObjetoIndisponivel)
                      }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


pub fn alterar_acessibilidade(
  jogo: Jogo,
  nome_ambiente: String,
  novo_estado: Bool,
) -> Result(Jogo, ErroJogo) {
  case jogo.situacao {
    Vitoria -> Error(JogoEncerrado)
    Derrota -> Error(JogoEncerrado)

    EmAndamento -> {
      case obter_fase_atual(jogo) {
        Error(erro) -> Error(erro)

        Ok(fase_atual) -> {
          case buscar_ambiente(fase_atual, nome_ambiente) {
            Error(Nil) -> Error(AmbienteNaoEncontrado)

            Ok(ambiente) -> {
              let novo_ambiente =
                Ambiente(..ambiente, acessivel: novo_estado)

              case atualizar_ambiente(fase_atual, novo_ambiente) {
                Error(Nil) -> Error(AmbienteNaoEncontrado)

                Ok(nova_fase) ->
                  Ok(salvar_fase_no_jogo(jogo, nova_fase))
              }
            }
          }
        }
      }
    }
  }
}

pub fn desbloquear_ambiente(
  jogo: Jogo,
  nome: String,
) -> Result(Jogo, ErroJogo) {
  alterar_acessibilidade(jogo, nome, True)
}

pub fn bloquear_ambiente(
  jogo: Jogo,
  nome: String,
) -> Result(Jogo, ErroJogo) {
  alterar_acessibilidade(jogo, nome, False)
}

pub fn gastar_tempo_atual(jogo: Jogo) -> Result(Jogo, ErroJogo) {
  case jogo.situacao {
    Vitoria -> Error(JogoEncerrado)
    Derrota -> Error(JogoEncerrado)

    EmAndamento -> {
      case obter_fase_atual(jogo) {
        Error(erro) -> Error(erro)

        Ok(fase_atual) -> {
          let nova_fase = gastar_tempo(fase_atual)
          Ok(salvar_fase_no_jogo(jogo, nova_fase))
        }
      }
    }
  }
}

pub fn concluir_fase_atual(jogo: Jogo) -> Result(Jogo, ErroJogo) {
  case jogo.situacao {
    Vitoria -> Error(JogoEncerrado)
    Derrota -> Error(JogoEncerrado)

    EmAndamento -> {
      case obter_fase_atual(jogo) {
        Error(erro) -> Error(erro)

        Ok(fase_atual) -> {
          case verificar_conclusao(fase_atual, jogo.jogador) {
            False -> Error(FaseNaoConcluida)

            True -> {
              let nova_fase = concluir_fase(fase_atual)
              Ok(salvar_fase_no_jogo(jogo, nova_fase))
            }
          }
        }
      }
    }
  }
}

fn buscar_proxima_fase(
  fases: List(Fase),
  id_atual: Int,
) -> Result(Fase, Nil) {
  case fases {
    [] -> Error(Nil)

    [prim, ..resto] ->
      case prim.id == id_atual {
        True -> {
          case resto {
            [] -> Error(Nil)
            [proxima, ..] -> Ok(proxima)
          }
        }

        False -> buscar_proxima_fase(resto, id_atual)
      }
  }
}

pub fn avancar_fase(jogo: Jogo) -> Result(Jogo, ErroJogo) {
  case jogo.situacao {
    Vitoria -> Error(JogoEncerrado)
    Derrota -> Error(JogoEncerrado)

    EmAndamento -> {
      case obter_fase_atual(jogo) {
        Error(erro) -> Error(erro)

        Ok(fase_atual) -> {
          case fase_atual.concluida {
            False -> Error(FaseNaoConcluida)

            True -> {
              case buscar_proxima_fase(jogo.fases, fase_atual.id) {
                Error(Nil) ->
                  Ok(altera_situacao(jogo, Vitoria))

                Ok(proxima_fase) -> {
                  case buscar_ambiente(
                    proxima_fase,
                    proxima_fase.ambiente_inicial,
                  ) {
                    Error(Nil) -> Error(AmbienteInicialInvalido)

                    Ok(ambiente_inicial) -> {
                      case ambiente_inicial.acessivel {
                        False -> Error(AmbienteInicialInvalido)

                        True -> {
                          let jogador_limpo =
                            jogador.reset_progresso(jogo.jogador)

                          let novo_jogador = jogador.mudar_local(
                            jogador_limpo,
                            proxima_fase.ambiente_inicial,
                          )

                          Ok(Jogo(
                            ..jogo,
                            jogador: novo_jogador,
                            fase_atual: proxima_fase.id,
                          ))
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


fn registrar_acao(jogo: Jogo) -> Result(Jogo, ErroJogo) {
  case gastar_tempo_atual(jogo) {
    Error(erro) -> Error(erro)

    Ok(novo_jogo) -> {
      case obter_fase_atual(novo_jogo) {
        Error(erro) -> Error(erro)

        Ok(fase_atual) -> {
          case verificar_conclusao(
            fase_atual,
            novo_jogo.jogador,
          ) {
            True -> {
              let fase_concluida = concluir_fase(fase_atual)
              Ok(salvar_fase_no_jogo(novo_jogo, fase_concluida))
            }

            False -> {
              case fase_atual.tempo <= 0 {
                True -> Ok(altera_situacao(novo_jogo, Derrota))
                False -> Ok(novo_jogo)
              }
            }
          }
        }
      }
    }
  }
}


fn verificar_conclusao(
  fase_atual: Fase,
  jogador: Jogador,
) -> Bool {
  case fase_atual.id {
    1 -> True
      // Verificar se os sistemas foram consertados
      // e se a mensagem foi recebida.

    2 -> True
      // Verificar se os cidadaos foram resgatados.

    3 -> True
      // Verificar se a rota segura foi descoberta.

    _ -> False
  }
}

fn registrar_falha_interacao(
  jogo: Jogo,
  falha: ErroJogo,
) -> Result(#(Jogo, ResultadoInteracao), ErroJogo) {
  case registrar_acao(jogo) {
    Error(erro) -> Error(erro)

    Ok(novo_jogo) ->
      Ok(#(
        novo_jogo,
        InteracaoComErro(falha),
      ))
  }
}

pub fn verificar_progresso(
  jogo: Jogo,
) -> Result(#(Jogo, Option(String)), ErroJogo) {
  case obter_fase_atual(jogo) {
    Error(erro) -> Error(erro)

    Ok(fase) -> {
      case fase.concluida {
        False -> Ok(#(jogo, None))

        True -> {
          case avancar_fase(jogo) {
            Error(erro) -> Error(erro)

            Ok(novo_jogo) -> {
              case novo_jogo.situacao {
                Vitoria -> Ok(#(
                  novo_jogo,
                  Some("Parabens! Voce concluiu todas as fases e venceu o jogo!"),
                ))

                _ -> Ok(#(
                  novo_jogo,
                  Some("Fase concluida! Avancando para a proxima fase..."),
                ))
              }
            }
          }
        }
      }
    }
  }
}


///
/// fase.gleam
///
pub type Fase {
  Fase(
    id: Int,
    tempo: Int,
    descricao: String,
    ambiente_inicial: String,
    ambientes: List(Ambiente),
    concluida: Bool,
  )
}


// Mostra a descricao da *fase* e suas opcoes de redirecionamento
pub fn explorar_fase(fase: Fase) -> String {
  "==== FASE " <> string.from_int(fase.id) <> " ====  \n \"" <> fase.descricao <> "\""
}

// Diminui o tempo limite da *fase*
pub fn gastar_tempo(fase: Fase) -> Fase {
  case fase.tempo > 0 {
    True -> Fase(..fase, tempo: fase.tempo - 1)
    False -> fase
  }
}

// Encontra se um ambiente esta entre *ambientes*
pub fn buscar_ambiente(fase: Fase, nome: String) -> Result(Ambiente, Nil) {
  buscar_ambiente_fase(fase.ambientes, nome)
}

pub fn buscar_ambiente_fase(ambientes: List(Ambiente), nome: String) -> Result(Ambiente, Nil) {
  case ambientes {
    [] -> Error(Nil)
    [prim, ..resto] ->
      case prim.nome == nome {
        True -> Ok(prim)
        False -> buscar_ambiente_fase(resto, nome)
      }
  }
}


// Descobre se um ambiente com *nome* esta acessivel na *fase*
pub fn verificar_acessibilidade(
  fase: Fase,
  nome: String,
) -> Result(Bool, Nil) {
  case buscar_ambiente(fase, nome) {
    Ok(ambiente) -> Ok(ambiente.acessivel)
    Error(Nil) -> Error(Nil)
  }
}

// Atualiza um ambiente da *fase*
pub fn atualizar_ambiente(
  fase: Fase,
  novo_ambiente: Ambiente,
) -> Result(Fase, Nil) {
  case buscar_ambiente(fase, novo_ambiente.nome) {
    Error(Nil) -> Error(Nil)

    Ok(_) -> {
      let novos_ambientes = list.map(
        fase.ambientes,
        fn(ambiente) {
          case ambiente.nome == novo_ambiente.nome {
            True -> novo_ambiente
            False -> ambiente
          }
        },
      )

      Ok(Fase(..fase, ambientes: novos_ambientes))
    }
  }
}

pub fn concluir_fase(fase: Fase) -> Fase {
  Fase(..fase, concluida: True)
}

// 
// ambiente.gleam
//
pub type Ambiente {
  Ambiente(
    nome: String,
    descricao: String,
    objetos: List(Objeto),
    saidas: List(String),
    acessivel: Bool,
  )
}

// Enumera cada string de uma *lista*
fn enumera(lista: List(String), index: Int) -> List(String) {
  case lista {
    [] -> []
    [prim, ..resto] -> ["  " <> string.from_int(index) <> ". " <> prim] ++ enumera(resto, index + 1)
  }
}

// Apresenta as informacoes gerais de um *ambi*
pub fn explorar_ambiente(ambiente: Ambiente) -> String {
  let obj_descricoes = list.map(ambiente.objetos, fn(obj) {examinar(obj)})
  let obj_formatados = case obj_descricoes {
    [] -> "Nenhum objeto aparente."
    _ -> " \n Objetos: " <> string.join(enumera(obj_descricoes, 1), "\n")
  }
  let saidas_formatados = enumera(ambiente.saidas, 1)
  string.join(
    ["---- " <> ambiente.nome <> " ----",
    "\"" <> ambiente.descricao <> "\"",
    obj_formatados,
    " \n Saidas: " <> string.join(saidas_formatados, "\n")], "\n",
  )
}

// Retorna um objeto com *nome* se ele estiver presente no ambiente
pub fn buscar_objeto(
  ambiente: Ambiente,
  nome: String,
) -> Result(Objeto, Nil) {
  buscar_objeto_lista(ambiente.objetos, nome)
}

fn buscar_objeto_lista(
  objetos: List(Objeto),
  nome: String,
) -> Result(Objeto, Nil) {
  case objetos {
    [] -> Error(Nil)

    [prim, ..resto] ->
      case prim.nome == nome {
        True -> Ok(prim)
        False -> buscar_objeto_lista(resto, nome)
      }
  }
}

pub fn inverter_acessibilidade(ambiente: Ambiente) -> Ambiente {
  Ambiente(..ambiente, acessivel: not ambiente.acessivel)
}

// Atualiza um objeto presente no ambiente
pub fn atualizar_objeto(
  ambiente: Ambiente,
  novo_objeto: Objeto,
) -> Result(Ambiente, Nil) {
  case buscar_objeto(ambiente, novo_objeto.nome) {
    Error(Nil) -> Error(Nil)

    Ok(_) -> {
      let novos_objetos = list.map(
        ambiente.objetos,
        fn(objeto) {
          case objeto.nome == novo_objeto.nome {
            True -> novo_objeto
            False -> objeto
          }
        },
      )

      Ok(Ambiente(..ambiente, objetos: novos_objetos))
    }
  }
}

//
// objeto.gleam
//
pub type Objeto {
  Objeto(
    nome: String,
    descricao: String,
    interacao: fn(Jogador) -> Jogador,
    estado: Estado,
  )
}

pub type Estado {
  Disponivel
  Indisponivel
  Quebrado(ferramenta: String, novo_estado: Estado)
  Coletavel
  Coletado
  RequerItem(item: String, novo_estado: Estado)
  DesbloqueiaAmbiente(
    item: String,
    ambiente: String,
    novo_estado: Estado,
  )
}

// Retorna a descricao de *obj* para o jogador
pub fn examinar(obj: Objeto) -> String {
  obj.descricao
  <> case obj.estado {
    Disponivel -> " - Esse objeto pode ser útil."
    Indisponivel -> " - Ja foi utilizado."
    Quebrado(_, _) -> " - Precisa ser consertado."
    Coletavel -> " - Pode ser coletado."
    Coletado -> " - Presente no inventario."
    RequerItem(_, _) ->
      " - Precisa de um item especifico para ser utilizado."
    DesbloqueiaAmbiente(_, _, _) ->
      " - Precisa de um item para desbloquear uma passagem."
  }
}

// Atualiza o estado de um *obj*
pub fn atualizar_estado(obj: Objeto, novo_estado: Estado) -> Objeto {
  Objeto(..obj, estado: novo_estado)
}

// Executa a interacao definida pelo *obj*
pub fn interagir(obj: Objeto, player: Jogador) -> Jogador {
  obj.interacao(player)
}

// Interação específica
// Coloca um *obj* no inventario do *player*
pub fn acao_coletar(nome_obj: String) -> fn(Jogador) -> Jogador {
  fn(player) { adicionar_obj(player, nome_obj) }
}

// Cria uma funcao de leitura de mensagem com *pista*
pub fn acao_ler_mensagem(pista: String) -> fn(Jogador) -> Jogador {
  fn(player) { adicionar_pista(player, pista) }
}

// Interação específica
// Faz um *obj* quebrado se tornar Disponivel
pub fn consertar(obj: Objeto, player: Jogador) -> Objeto {
  case obj.estado {
    Quebrado(ferramenta, novo_estado) -> {
      case possui_obj(player, ferramenta) {
        True -> atualizar_estado(obj, novo_estado)
        False -> obj
      }
    }
    _ -> obj
  }
}

// 
// jogador.gleam
//
pub type Jogador {
  Jogador(
    nome: String,
    local: String,
    inventario: List(String),
    pistas: List(String),
  )
}

// Adiciona um *obj*, pelo seu nome, ao inventario
pub fn adicionar_obj(player: Jogador, obj: String) -> Jogador {
  case possui_obj(player, obj) {
    True -> player
    False ->
      Jogador(..player, inventario: list.append(player.inventario, [obj]))
  }
}

// Remove *obj*, pelo seu nome, do inventario
pub fn gastar_obj(player: Jogador, obj: String) -> Jogador {
  Jogador(
    ..player,
    inventario: list.filter(player.inventario, fn(x) { x != obj }),
  )
}

// Registra uma *pista* descoberta
pub fn adicionar_pista(player: Jogador, pista: String) -> Jogador {
  case possui_pista(player, pista) {
    True -> player
    False -> Jogador(..player, pistas: list.append(player.pistas, [pista]))
  }
}

// Verifica se o *player* possui determinado *obj*
pub fn possui_obj(player: Jogador, obj: String) -> Bool {
  lista_contem(player.inventario, obj)
}

// Verifica se o *player* ja descobriu determinada *pista*
pub fn possui_pista(player: Jogador, pista: String) -> Bool {
  lista_contem(player.pistas, pista)
}

// Verifica se um elemento aparece em uma lista
fn lista_contem(lista: List(String), nome: String) -> Bool {
  case lista {
    [] -> False
    [prim, ..resto] ->
      case prim == nome {
        True -> True
        False -> lista_contem(resto, nome)
      }
  }
}

// Atualiza a localizacao do *player*
pub fn mudar_local(player: Jogador, novo_loc: String) -> Jogador {
  Jogador(..player, local: novo_loc)
}

pub fn reset_progresso(player: Jogador) -> Jogador {
  Jogador(..player, inventario: [], pistas: [])
}
