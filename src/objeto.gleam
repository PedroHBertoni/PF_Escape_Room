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
  Coletado
  Quebrado
  Indisponivel
}

// Executa sua interação, desde que *objeto* esteja disponível
pub fn interagir(objeto: Objeto, jogador: jogador.Jogador) -> jogador.Jogador {
  case objeto.estado {
    Disponivel -> objeto.interacao(jogador_atual)
    _ -> jogador_atual
  }
}

// Atualiza o estado de um objeto
pub fn atualizar_estado(objeto: Objeto, novo_estado: Estado) -> Objeto {
  Objeto(..objeto, estado: novo_estado)
}

// Interação específica para objetos coletáveis
pub fn pegar_objeto(jogador: jogador.Jogador, obj: String) -> jogador.Jogador {
  jogador.adicionar_item(jogador_atual, obj_nome)
}
