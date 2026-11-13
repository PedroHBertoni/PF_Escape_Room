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
  estado: EstadoJogo,
  opcao: MainMenu,
) -> Result(#(EstadoJogo, ResultadoMenu), Nil) {
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
        [] -> "Inventário vazio."
        _ -> "Inventário: " <> string.join(itens, ", ")
      }
      Ok(#(estado, Mostrar(texto)))
    }

    Pistas -> {
      let pistas = estado.jogador.pistas
      let texto = case pistas {
        [] -> "Nenhuma pista."
        _ -> "Pistas: " <> string.join(itens, ", ")
      }
      Ok(#(estado, Mostrar(texto)))
    }
    Sair -> Ok(#(estado, Encerrar))
  }
}

// 
// jogo.gleam
// 
pub type EstadoJogo {
  EstadoJogo(
    jogador: Jogador,
    ambientes: List(Ambiente),
    situacao: SituacaoJogo,
  )
}

pub type SituacaoJogo {
  EmAndamento
  Vitoria
  Derrota
}

// Mostra as opções do ambiente onde está o jogador
pub fn explorar_atual(estado: EstadoJogo) -> Result(String, Nil) {
  case buscar_ambiente_atual(estado) {
    Ok(local) -> Ok(ambiente.explorar(local, estado.jogador))

    Error(Nil) -> Error(Nil)
  }
}

// Caso a *resposta* solucione o enigma, ou não, retorna o novo EstadoJogo
pub fn tentar_resolver_enigma(
  estado: EstadoJogo,
  enigma: String,
  resposta: String,
) -> Result(#(EstadoJogo, ResultadoEnigma), Nil) {
  case buscar_ambiente_atual(estado) {
    Ok(local) ->
      case ambiente.buscar_enigma(local, enigma) {
        Ok(desafio) -> {
          let resultado =
            enigma.resolver_enigma(desafio, resposta, estado.jogador)

          let jogador_atualizado = case resultado {
            enigma.EnigmaResolvido(jogador_atualizado) -> jogador_atualizado
            enigma.RespostaIncorreta(jogador_atual) -> jogador_atual
            enigma.EnigmaJaResolvido(jogador_atual) -> jogador_atual
          }

          let estado_atualizado =
            EstadoJogo(..estado, jogador: jogador_atualizado)

          Ok(#(estado_atualizado, resultado))
        }

        Error(Nil) -> Error(Nil)
      }

    Error(Nil) -> Error(Nil)
  }
}

// Aplica a interação de um objeto de forma genérica
pub fn interagir_com_objeto(
  estado: EstadoJogo,
  nome_objeto: String,
) -> Result(EstadoJogo, Nil) {
  case buscar_ambiente_atual(estado) {
    Ok(local) ->
      case ambiente.buscar_objeto(local, nome_objeto) {
        Ok(obj) -> {
          let jogador_atualizado = objeto.interagir(obj, estado.jogador)

          Ok(EstadoJogo(..estado, jogador: jogador_atualizado))
        }

        Error(Nil) -> Error(Nil)
      }

    Error(Nil) -> Error(Nil)
  }
}

// Busca o ambiente que representa a localização do jogador
pub fn buscar_ambiente_atual(
  estado: EstadoJogo,
) -> Result(ambiente.Ambiente, Nil) {
  buscar_ambiente(estado.ambientes, estado.jogador.localizacao)
}

// aux de buscar_ambiente_atual
fn buscar_ambiente(
  ambientes: List(ambiente.Ambiente),
  nome: String,
) -> Result(ambiente.Ambiente, Nil) {
  case ambientes {
    [] -> Error(Nil)
    [prim, ..resto] ->
      case prim.nome == nome {
        True -> Ok(prim)
        False -> buscar_ambiente(resto, nome)
      }
  }
}

// Finaliza o jogo com Vitória
pub fn finalizar_com_vitoria(estado: EstadoJogo) -> EstadoJogo {
  EstadoJogo(..estado, situacao: Vitoria)
}

// Finaliza o jogo com Derrota
pub fn finalizar_com_derrota(estado: EstadoJogo) -> EstadoJogo {
  EstadoJogo(..estado, situacao: Derrota)
}

pub fn jogo_foi_finalizado(estado: EstadoJogo) -> Bool {
  case estado.situacao {
    EmAndamento -> False
    _ -> True
  }
}

// 
// ambiente.gleam
//
pub type Ambiente {
  Ambiente(
    nome: String,
    descricao: String,
    objetos: List(objeto.Objeto),
    saidas: List(String),
    enigmas: List(enigma.Enigma),
  )
}

// Apresenta as informações gerais de um ambiente
pub fn explorar(ambiente: Ambiente) -> String {
  let objetos_txt = listar_objetos(ambiente)
  let enigmas_txt = listar_enigmas(ambiente)

  string.join(
    [
      ambiente.nome,
      ambiente.descricao,
      "Objetos: " <> string.join(objetos_txt, ", "),
      "Saídas: " <> string.join(ambiente.saidas, ", "),
      "Enigmas: " <> string.join(enigmas_txt, ", "),
    ],
    "\n",
  )
}

// Retorna os nomes dos objetos presentes
pub fn listar_objetos(ambiente: Ambiente) -> List(String) {
  list.map(ambiente.objetos, fn(obj) { obj.nome })
}

// Retorna os nomes dos enigmas presentes
pub fn listar_enigmas(ambiente: Ambiente) -> List(String) {
  list.map(ambiente.enigmas, fn(enigma) { enigma.nome })
}

// Verifica se determinada saída pertence ao ambiente.
pub fn verificar_saida(ambiente: Ambiente, destino: String) -> Bool {
  contem_texto(ambiente.saidas, destino)
}

// Busca um objeto no ambiente
pub fn buscar_objeto(
  ambiente: Ambiente,
  nome: String,
) -> Result(objeto.Objeto, Nil) {
  buscar_objeto_lista(ambiente.objetos, nome)
}

// Busca um enigma no ambiente
pub fn buscar_enigma(
  ambiente: Ambiente,
  nome: String,
) -> Result(enigma.Enigma, Nil) {
  buscar_enigma_lista(ambiente.enigmas, nome)
}

// Verifica se um texto está presente em uma lista.
fn contem_texto(lista: List(String), texto: String) -> Bool {
  case lista {
    [] -> False
    [prim, ..] if prim == texto -> True
    [_, ..resto] -> contem_texto(resto, texto)
  }
}

// Procura um objeto recursivamente
fn buscar_objeto_lista(
  objetos: List(objeto.Objeto),
  nome: String,
) -> Result(objeto.Objeto, Nil) {
  case objetos {
    [] -> Error(Nil)
    [prim, ..] if prim.nome == nome -> Ok(prim)
    [_, ..resto] -> buscar_objeto_lista(resto, nome)
  }
}

// Procura um enigma recursivamente
fn buscar_enigma_lista(
  enigmas: List(enigma.Enigma),
  nome: String,
) -> Result(enigma.Enigma, Nil) {
  case enigmas {
    [] -> Error(Nil)
    [prim, ..] if prim.nome == nome -> Ok(prim)
    [_, ..resto] -> buscar_enigma_lista(resto, nome)
  }
}

//
// objeto.gleam
//
pub type Objeto {
  Objeto(
    nome: String,
    descricao: String,
    interacao: fn(jogador.Jogador) -> jogador.Jogador,
    estado: Estado,
  )
}

pub type Estado {
  Disponivel
  Coletado
  Indisponivel
}

// Retorna a descricao de *obj* para o jogador
pub fn examinar(obj: Objeto) -> String {
    obj.descricao
}

// Executa sua interacao, desde que *obj* esteja disponivel
pub fn interagir(obj: Objeto, player: Jogador) -> Jogador {
  case obj.estado {
    Disponivel -> obj.interacao(player)
    _ -> player
  }
}

// Atualiza o estado de um *obj*
pub fn atualizar_estado(obj: Objeto, novo_estado: Estado) -> Objeto {
  Objeto(..obj, estado: novo_estado)
}

// Interação específica
// Coloca um *obj* no inventario do *player*
pub fn pegar_objeto(player: Jogador, obj: Objeto) -> Jogador {
  player.adicionar_item(player, obj)
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
    inventario: List(Objeto),
    pistas: List(String),
    vida: Bool,
    localizacao: String,
  )
}

// Verifica se o *player* ja possui *item*
pub fn possui_item(player: Jogador, item: String) -> Bool {
  lista_contem(player.inventario, item)
}

// Verifica se o *player* ja viu *pista*
pub fn possui_pista(player: Jogador, pista: String) -> Bool {
  lista_contem(player.pistas, pista)
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

// Adiciona um *item* ao *inventario*
pub fn adicionar_item(player: Jogador, item: String) -> Jogador {
  Jogador(..player, inventario: list.append(player.inventario, [item]))
}

// Remove *item* do *inventário*
pub fn gastar_item(player: Jogador, item: String) -> Jogador {
  Jogador(
    ..player,
    inventario: list.filter(player.inventario, fn(x) { x != item }),
  )
}

// Registra uma *pista* descoberta
pub fn adicionar_pista(player: Jogador, pista: String) -> Jogador {
  case possui_pista(player, pista) {
    True -> player
    False -> Jogador(..player, pistas: list.append(player.pistas, [pista]))
  }
}

// Reseta as pistas do *player* na troca de fases
pub fn reset_pistas(player: Jogador) -> Jogador {
  Jogador(..player, pistas: [])
}

// Tira a vida do *player*
pub fn morrer(player: Jogador) -> Jogador {
  Jogador(..player, vida: False)
}

// Atualiza a localização do *player* para *loc*
pub fn trocar_localizacao(player: Jogador, loc: String) -> Jogador {
  Jogador(..player, localizacao: loc)
}