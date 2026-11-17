
import jogador

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
  Indisponivel
  Quebrado(ferramenta: String, novo_estado: Estado)
  Coletavel
  Coletado
}

// Retorna a descricao do objeto para o jogador
pub fn examinar(obj: Objeto) -> String {
  obj.descricao <> case obj.estado {
    Disponivel -> " - Esse objeto pode ser útil."
    Indisponivel -> " - Ja foi utilizado."
    Quebrado(_, _) -> " - Precisa ser consertado."
    Coletavel -> " - Pode ser coletado."
    Coletado -> " - Presente no inventario."
  }
}

// Atualiza o estado de um objeto
pub fn atualizar_estado(obj: Objeto, novo_estado: Estado) -> Objeto {
  Objeto(..obj, estado: novo_estado)
}

// Executa a interacao definida pelo objeto
pub fn interagir(obj: Objeto, player: jogador.Jogador) -> jogador.Jogador {
  obj.interacao(player)
}

// Cria uma funcao de coleta para determinado objeto
pub fn acao_coletar(nome_obj: String) -> fn(jogador.Jogador) -> jogador.Jogador {
  fn(player) {jogador.adicionar_obj(player, nome_obj)}
}

// Cria uma funcao de leitura de mensagem com *pista*
pub fn acao_ler_mensagem(pista: String) -> fn(jogador.Jogador) -> jogador.Jogador {
  fn(player) {jogador.adicionar_pista(player, pista)}
}


// Conserta um objeto caso o jogador possua a ferramenta necessaria
pub fn consertar(
  obj: Objeto,
  player: jogador.Jogador,
) -> Objeto {
  case obj.estado {
    Quebrado(ferramenta, novo_estado) -> {
      case jogador.possui_obj(player, ferramenta) {
        True -> atualizar_estado(obj, novo_estado)
        False -> obj
      }
    }
    _ -> obj
  }
}