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
      let itens = list.map(estado.jogador.inventario, fn(x) {x.nome})
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
    fase_atual: SituacaoJogo,
  )
}

pub type SituacaoJogo {
  EmAndamento
  Vitoria
  Derrota
}

// Mostra as informacoes do Ambiente onde esta o jogador
pub fn explorar_ambiente(jogo: Jogo) -> String {
  explorar(jogador.localizacao)
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

///
/// fase.gleam
///
pub type Fase {
  Fase(
    id: Int,
    ambientes: List(Ambiente),
    inventario: List(Objeto),
    pistas: List(String),
  )
}

// Adiciona um *obj* ao inventario
pub fn adicionar_obj(fase: Fase, obj: Objeto) -> Fase {
  Fase(..fase, inventario: list.append(fase.inventario, [obj]))
}

// Remove *obj* do inventario
pub fn gastar_obj(fase: Fase, obj: String) -> Fase {
  Fase(..fase, inventario: list.filter(fase.inventario, fn(x) {x.nome != obj}))
}

// Registra uma *pista* descoberta
pub fn adicionar_pista(fase: Fase, pista: String) -> Fase {
  case possui_pista(fase, pista) {
    True -> fase
    False -> Fase(..fase, pistas: list.append(jogo.pistas, [pista]))
  }

}

// Verifica se o *obj* ja foi coletado
pub fn possui_obj(fase: Fase, obj: String) -> Bool {
  lista_contem(list.map(fase.inventario, fn(x) {x.nome}), obj)
}

// Verifica se a *pista* ja foi vista
pub fn possui_pista(fase: Fase, pista: String) -> Bool {
  lista_contem(fase.pistas, pista)
}

// Verifica se *nome* aparece em uma *lista*
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

// Aplica a interacao de um objeto de forma generica
pub fn interacao(jogo: Jogo, nome_obj: Objeto) -> Result(Fase, Nil) {
  case buscar_objeto(jogo.jogador.localizacao, nome_obj) {
    Ok(obj) -> {
      Ok(Jogo(..estado, objeto: objeto.interagir(obj, estado.jogador)))
    }
    Error(Nil) -> Error(Nil)
  }
Error(Nil) -> Error(Nil)
}

// 
// ambiente.gleam
//
pub type Ambiente {
  Ambiente(
    nome: String,
    descricao: String,
    objetos: List(Objeto),
    resolvido: Bool,
  )
}

// Apresenta as informacoes gerais de um *ambi*
pub fn explorar(ambiente: Ambiente) -> String {
  let objetos_nomes = list.map(salas, fn(x) {x.nome})
  string.join([nome, descricao, ..salas_nomes], "\n")
}

// Retorna um tipo com *nome* se esse está presente
fn buscar(lista: List(a), nome: String) -> Result(a, Nil) {
  case lista {
    [] -> Error(Nil)
    [prim, ..resto] -> case prim.nome == nome {
      True -> Ok(prim)
      False -> buscar(resto, nome)
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
    interacao: AcaoObjeto,
    estado: Estado,
  )
}

pub type Estado {
  Disponivel
  Indisponivel
  Coletavel
  Coletado
}

pub type AcaoObjeto {
  Coletar(interacao: fn(Objeto) -> Objeto = pegar_objeto())
  RevelarPista(pista: String)
  AbrirPassagem
  Nenhuma
}

// Retorna a descricao de *obj* para o jogador
pub fn examinar(obj: Objeto) -> String {
  obj.descricao
}

// Atualiza o estado de um *obj*
pub fn atualizar_estado(obj: Objeto, novo_estado: Estado) -> Objeto {
  Objeto(..obj, estado: novo_estado)
}

// Interação específica
// Coloca um *obj* no inventario do *player*
pub fn pegar_objeto(obj: Objeto) -> Jogador {
  jogador.adicionar_item(player, obj)
}

// Interação específica
// Faz um *obj* quebrado se tornar Disponivel
fn consertar(obj: Objeto) -> Objeto {
  atualizar_estado(obj, Disponivel)
}

// 
// jogador.gleam
//
pub type Jogador {
  Jogador(
    nome: String,
    vida: Int,
    localizacao: Ambiente,
  )
}

// Tira a vida do *player*
pub fn gastar_tempo(player: Jogador) -> Jogador {
  Jogador(..player, vida: player.vida - 1)
}

// Atualiza a localização do *player* para *loc*
fn trocar_localizacao(player: Jogador, loc: Ambiente) -> Jogador {
  Jogador(..player, localizacao: loc)
}