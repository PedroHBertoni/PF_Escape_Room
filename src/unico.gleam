import gleam/io
import gleam/list
import gleam/string

// 
// menus.gleam
//
pub type MainMenu {
  Explorar
  Inventario
  Pistas
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

pub fn exit() -> MainMenu {
  Sair
}

// Executa a opção escolhida
pub fn executar_opcao(
  estado: Jogo,
  opcao: MainMenu,
) -> Result(#(Jogo, ResultadoMenu), Nil) {
  case opcao {
    Explorar -> {
      case explorar_atual(estado) {
        Ok(texto) -> Ok(#(estado, Mostrar(texto)))
        Error(Nil) -> Error(Nil)
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
    Sair -> Ok(#(estado, Encerrar))
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

// Mostra as informacoes do Ambiente onde esta o jogador
pub fn explorar_atual(jogo: Jogo) -> Result(String, ErroJogo) {
  case obter_ambiente_atual(jogo) {
    Error(erro) -> Error(erro)

    Ok(ambiente) -> {
      case ambiente.acessivel {
        True -> Ok(ambiente.explorar_ambiente(ambiente))
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

// Aplica a interacao de um objeto de forma generica
pub fn interacao(jogo: Jogo, nome_obj: String) -> Result(Jogo, Nil) {
  case buscar_objeto(jogo.jogador.local, nome_obj) {
    Ok(obj) -> {
      Ok(Jogo(..jogo, jogador: jogador.interagir(obj, jogo.jogador)))
     }
    Error(Nil) -> Error(Nil)
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
      case fase.buscar_ambiente(fase, jogo.jogador.local) {
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
                  case fase.buscar_ambiente(fase, destino) {
                    Error(Nil) -> Error(AmbienteNaoEncontrado)

                    Ok(ambiente_destino) -> {
                      case ambiente_destino.acessivel {
                        False -> Error(AmbienteInacessivel)

                        True -> {
                          let jogador_atualizado =
                            jogador.mudar_local(jogo.jogador, destino)

                          Ok(Jogo(
                            ..jogo,
                            jogador: jogador_atualizado,
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
) -> Result(Jogo, ErroJogo) {
  case ambiente.atualizar_objeto(ambiente_atual, novo_objeto) {
    Error(Nil) -> Error(ObjetoNaoEncontrado)

    Ok(novo_ambiente) -> {
      case fase.atualizar_ambiente(fase_atual, novo_ambiente) {
        Error(Nil) -> Error(AmbienteNaoEncontrado)

        Ok(nova_fase) -> {
          let jogo_atualizado =
            salvar_fase_no_jogo(jogo, nova_fase)

          Ok(Jogo(
            ..jogo_atualizado,
            jogador: novo_jogador,
          ))
        }
      }
    }
  }
}

pub fn interagir_objeto(
  jogo: Jogo,
  nome_obj: String,
) -> Result(Jogo, ErroJogo) {
  case jogo.situacao {
    Vitoria -> Error(JogoEncerrado)
    Derrota -> Error(JogoEncerrado)

    EmAndamento -> {
      case obter_fase_atual(jogo) {
        Error(erro) -> Error(erro)

        Ok(fase_atual) -> {
          case fase.buscar_ambiente(fase_atual, jogo.jogador.local) {
            Error(Nil) -> Error(AmbienteNaoEncontrado)

            Ok(ambiente_atual) -> {
              case ambiente.buscar_objeto(ambiente_atual, nome_obj) {
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

                          salvar_interacao(
                            jogo,
                            fase_atual,
                            ambiente_atual,
                            novo_objeto,
                            novo_jogador,
                          )
                        }

                        Disponivel -> {
                          let novo_jogador =
                            objeto.interagir(obj, jogo.jogador)

                          let novo_objeto =
                            objeto.atualizar_estado(obj, Indisponivel)

                          salvar_interacao(
                            jogo,
                            fase_atual,
                            ambiente_atual,
                            novo_objeto,
                            novo_jogador,
                          )
                        }

                        Quebrado(ferramenta, _) -> {
                          case jogador.possui_obj(jogo.jogador, ferramenta) {
                            False -> Error(FerramentaAusente(ferramenta))

                            True -> {
                              let novo_objeto =
                                objeto.consertar(obj, jogo.jogador)

                              salvar_interacao(
                                jogo,
                                fase_atual,
                                ambiente_atual,
                                novo_objeto,
                                jogo.jogador,
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
          case fase.buscar_ambiente(fase_atual, nome_ambiente) {
            Error(Nil) -> Error(AmbienteNaoEncontrado)

            Ok(ambiente) -> {
              let novo_ambiente =
                Ambiente(..ambiente, acessivel: novo_estado)

              case fase.atualizar_ambiente(fase_atual, novo_ambiente) {
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
          let nova_fase = fase.gastar_tempo(fase_atual)
          let novo_jogo = salvar_fase_no_jogo(jogo, nova_fase)

          case nova_fase.tempo == 0 {
            True -> Ok(altera_situacao(novo_jogo, Derrota))
            False -> Ok(novo_jogo)
          }
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
          let nova_fase = fase.concluir_fase(fase_atual)
          Ok(salvar_fase_no_jogo(jogo, nova_fase))
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
                  case fase.buscar_ambiente(
                    proxima_fase,
                    proxima_fase.ambiente_inicial,
                  ) {
                    Error(Nil) -> Error(AmbienteInicialInvalido)

                    Ok(ambiente_inicial) -> {
                      case ambiente_inicial.acessivel {
                        False -> Error(AmbienteInicialInvalido)

                        True -> {
                          let novo_jogador = jogador.mudar_local(
                            jogo.jogador,
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
fn buscar_ambiente(ambientes: List(Ambiente), nome: String) -> Result(Ambiente, Nil) {
  case ambientes {
    [] -> Error(Nil)
    [prim, ..resto] ->
      case prim.nome == nome {
        True -> Ok(prim)
        False -> buscar_ambiente(resto, nome)
      }
  }
}

// Descobre se um ambiente com *nome* esta acessivel na *fase*
pub fn verificar_acessibilidade(fase: Fase, nome: String) -> Result(Bool, Nil) {
  case buscar_ambiente(fase.ambientes, nome) {
    Ok(ambiente) -> Ok(ambiente.acessivel)
    Error(Nil) -> Error(Nil)
  }
}

// Atualiza um ambiente da *fase*
pub fn atualizar_ambiente(fase: Fase, novo_ambiente: Ambiente) -> Result(Fase, Nil) {
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
  let obj_descricoes = list.map(ambiente.objetos, fn(obj) {objeto.examinar(obj)})
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

// Retorna um objeto com *nome* se esse está presente
fn buscar_objeto(lista: List(Objeto), nome: String) -> Result(Objeto, Nil) {
  case lista {
    [] -> Error(Nil)
    [prim, ..resto] ->
      case prim.nome == nome {
        True -> Ok(prim)
        False -> buscar_objeto(resto, nome)
      }
  }
}

pub fn inverter_acessibilidade(ambiente: Ambiente) -> Ambiente {
  Ambiente(..ambiente, acessivel: not ambiente.acessivel)
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