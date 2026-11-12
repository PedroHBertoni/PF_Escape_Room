
import gleam/list
import gleam/string

import enigma
import objeto
import jogador

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
pub fn buscar_objeto(ambiente: Ambiente, nome: String) -> Result(objeto.Objeto, Nil) {
  buscar_objeto_lista(ambiente.objetos, nome)
}

// Busca um enigma no ambiente
pub fn buscar_enigma(ambiente: Ambiente,nome: String) -> Result(enigma.Enigma, Nil) {
  buscar_enigma_lista(ambiente.enigmas, nome)
}

// Verifica se um texto está presente em uma lista.
fn contem_texto(lista: List(String), texto: String) -> Bool {
  case lista {
    [] -> False
    [prim, .._] if prim == texto -> True
    [_, ..resto] -> contem_texto(resto, texto)
  }
}

// Procura um objeto recursivamente
fn buscar_objeto_lista(objetos: List(objeto.Objeto), nome: String) -> Result(objeto.Objeto, Nil) {
  case objetos {
    [] -> Error(Nil)
    [prim, .._] if prim.nome == nome -> Ok(prim)
    [_, ..resto] -> buscar_objeto_lista(resto, nome)
  }
}

// Procura um enigma recursivamente
fn buscar_enigma_lista(enigmas: List(enigma.Enigma), nome: String) -> Result(enigma.Enigma, Nil) {
  case enigmas {
    [] -> Error(Nil)
    [prim, .._] if prim.nome == nome -> Ok(prim)
    [_, ..resto] -> buscar_enigma_lista(resto, nome)
  }
}
