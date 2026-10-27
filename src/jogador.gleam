pub type Jogador {
  Jogador(
    nome: String,
    inventario: List(String),
    pontos_de_vida: Int,
    localizacao: String,
  )
}

pub fn adicionar_item(jogador: Jogador, item: String) -> Jogador {
  Jogador(..jogador, inventario: list.append(jogador.inventario, item))
}

pub fn gastar_item(jogador: Jogador, item: String) -> Jogador {
  fn encontra_elemento(nome: String) -> Bool {nome == item.nome}
  Jogador(..jogador, inventario: list.filter(jogador.inventario, tirar_elemento))
}

pub fn tomar_dano(jogador: Jogador) -> Jogador {
  Jogador(..jogador, pontos_de_vida: jogador.pontos_de_vida -1)
}

pub fn curar(jogador: Jogador)-> Jogador {
  Jogador(..jogador, pontos_de_vida: jogador.pontos_de_vida +1)
}

pub fn trocar_localizacao(jogador: Jogador, loc: String) -> Jogador {
  Jogador(..jogador, localizacao: loc)
}

