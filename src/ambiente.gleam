import enigma
import objeto

pub type Ambiente {
  Ambiente(
    nome: String,
    descricao: String,
    objetos: List(objeto.Objeto),
    saidas: List(String),
    enigmas: List(enigma.Enigma),
  )
}
