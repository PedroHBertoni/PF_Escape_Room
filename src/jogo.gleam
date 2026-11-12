
import ambiente
import enigma
import jogador
import objeto

pub type EstadoJogo {
  EstadoJogo(
    jogador: jogador.Jogador,
    ambientes: List(ambiente.Ambiente),
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
    Ok(local) ->
      Ok(ambiente.explorar(local, estado.jogador))

    Error(Nil) -> Error(Nil)
  }
}

// Caso a *resposta* solucione o enigma, ou não, atualiza um EstadoJogo e que
// chegou no ResultadoEnigma
pub fn tentar_resolver_enigma(estado: EstadoJogo, enigma: String, resposta: String) -> Result(#(EstadoJogo, enigma.ResultadoEnigma), Nil) {
  case buscar_ambiente_atual(estado) {
    Ok(local) ->
      case ambiente.buscar_enigma(local, enigma) {
        Ok(desafio) -> {
          let resultado = enigma.resolver_enigma(desafio, resposta, estado.jogador)

          let jogador_atualizado = case resultado {
            enigma.EnigmaResolvido(jogador_atualizado) -> jogador_atualizado
            enigma.RespostaIncorreta(jogador_atual) -> jogador_atual
            enigma.EnigmaJaResolvido(jogador_atual) -> jogador_atual
          }

          let estado_atualizado = EstadoJogo(..estado, jogador: jogador_atualizado)

          Ok(#(estado_atualizado, resultado))
        }

        Error(Nil) -> Error(Nil)
      }

    Error(Nil) -> Error(Nil)
  }
}

// Aplica a interação de um objeto de forma genérica
pub fn interagir_com_objeto(estado: EstadoJogo, nome_objeto: String) -> Result(EstadoJogo, Nil) {
  case buscar_ambiente_atual(estado) {
    Ok(local) ->
      case ambiente.buscar_objeto(local, nome_objeto) {
        Ok(obj) -> {
          let jogador_atualizado =
            objeto.interagir(obj, estado.jogador)

          Ok(EstadoJogo(..estado, jogador: jogador_atualizado))
        }

        Error(Nil) -> Error(Nil)
      }

    Error(Nil) -> Error(Nil)
  }
}

// Busca o ambiente que representa a localização do jogador
pub fn buscar_ambiente_atual(estado: EstadoJogo) -> Result(ambiente.Ambiente, Nil) {
  buscar_ambiente(estado.ambientes, estado.jogador.localizacao)
}
// aux de buscar_ambiente_atual
fn buscar_ambiente(ambientes: List(ambiente.Ambiente), nome: String) -> Result(ambiente.Ambiente, Nil) {
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
