pub type Enigma {
  Enigma(
    descricao: String,
    solucao: String,
    pistas: List(String),
    efeito: fn(Jogador) -> Jogador,
  )
}

pub fn resolver_enigma(
  enigma: Enigma,
  resposta: String,
  jogador_atual: jogador.Jogador,
) -> jogador.Jogador {
  case resposta == enigma.solucao {
    True -> enigma.efeito(jogador_atual)
    False -> jogador_atual
  }
}
