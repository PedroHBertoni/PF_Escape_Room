pub type Jogador {
    Jogador(
        nome: String,
        inventario: List(String),
        pontos_de_vida: Int,
        localizacao: String,
    )
}

pub fn adicionar_item(
  jogador: Jogador,
  item: String,
) -> Jogador {
  Jogador(
    ..jogador,
    inventario: [item, ..jogador.inventario],
  )
}
