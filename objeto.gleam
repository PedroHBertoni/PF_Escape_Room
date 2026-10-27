pub type Objeto {
    Objeto(
        nome: String,
        descricao: String,
        interacao: fn(Jogador) -> Jogador,
        estado: String,
    )
}

pub fn pegar_objeto(jogador_atual: jogador.Jogador) -> jogador.Jogador {
  jogador.adicionar_item(jogador_atual, obj.nome)
}
