import jogador

pub type Objeto {
  Objeto(
    nome: String,
    descricao: String,
    interacao: fn(a) -> a,
    estado: Estado,
  )
}

pub type Estado {
    Disponivel,
    Coletado,
    Quebrado,
    Indisponivel
}

fn pegar_objeto(
  jogador_atual: jogador.Jogador,
  obj_nome: String,
) -> jogador.Jogador {
    jogador.adicionar_item(jogador_atual, obj_nome)
}

fn abrir()