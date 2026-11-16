import objeto

pub type Personagem {
  Personagem(
    nome: String,
    descricao: String,
    interacao: fn(Personagem) -> String,
  )
}

pub fn interagir(personagem: Personagem) -> String {
    personagem.interacao(personagem)
}

