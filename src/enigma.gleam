import jogador

pub type Enigma {
  Enigma(
    nome: String,
    descricao: String,
    solucao: String,
    pistas: List(String),
    efeito: fn(jogador.Jogador) -> jogador.Jogador,
  )
}

// Representa os possíveis resultados de uma tentativa
pub type ResultadoEnigma {
  EnigmaResolvido(jogador_atualizado: jogador.Jogador)
  RespostaIncorreta(jogador_atual: jogador.Jogador)
  EnigmaJaResolvido(jogador_atual: jogador.Jogador)
}

// Consulta uma pista específica e registra sua descoberta
pub fn consultar_pista(
  enigma: Enigma,
  numero_pista: Int,
  jogador: jogador.Jogador,
) -> Result(#(String, jogador.Jogador), Nil) {
  case buscar_pista(enigma.pistas, numero_pista) {
    Ok(pista) -> {
      let jogador_atualizado = jogador.adicionar_pista(jogador_atual, pista)
      Ok(#(pista, jogador_atualizado))
    }
    Error(Nil) -> Error(Nil)
  }
}

// 
fn buscar_pista(pistas: List(String), numero: Int) -> Result(String, Nil) {
  case pistas {
    [] -> Error(Nil)
    [pista, ..resto] ->
      case numero {
        1 -> Ok(pista)
        _ -> buscar_pista(resto, numero - 1)
      }
  }
}

// Verifica uma resposta e aplica o efeito do enigma caso esteja correta.
pub fn resolver_enigma(
  enigma: Enigma,
  resposta: String,
  jogador: jogador.Jogador,
) -> ResultadoEnigma {
  case jogador.ja_resolveu_enigma(jogador, enigma.nome) {
    True -> EnigmaJaResolvido(jogador)
    False ->
      case resposta == enigma.solucao {
        True -> {
          let jogador_com_efeito = enigma.efeito(jogador)

          let jogador_atualizado =
            jogador.registrar_enigma_resolvido(jogador_com_efeito, enigma.nome)

          EnigmaResolvido(jogador_atualizado)
        }
        False -> RespostaIncorreta(jogador_atual)
      }
  }
}
