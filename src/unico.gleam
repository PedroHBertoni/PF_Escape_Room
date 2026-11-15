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

// Mostra as informacoes do Ambiente onde esta o jogador
pub fn explorar_atual(jogo: Jogo) -> String {
  explorar_ambiente(jogo.jogador.local)
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
Error(Nil) -> Error(Nil)
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
  Fase(..fase, tempo: fase.tempo - 1)
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