import gleam/list

pub type Jogador {
  Jogador(
    nome: String,
    inventario: List(String),
    vida: Bool,
    localizacao: String,
    pistas_descobertas: List(String),
    enigmas_resolvidos: List(String),
  )
}

// Verifica se o jogadorjá possui *item*
pub fn possui_item(jogador: Jogador, item: String) -> Bool {
  lista_contem(jogador.inventario, item)
}

// Verifica se *nome* aparece em uma *lista8
fn lista_contem(lista: List(String), nome: String) -> Bool {
  case lista {
    [] -> False
    [prim, ..resto] ->
      case prim == nome {
        True -> True
        False -> lista_contem(resto, nome)
      }
  }
}

// Adiciona um item ao inventário
pub fn adicionar_item(jogador: Jogador, item: String) -> Jogador {
  Jogador(..jogador, inventario: list.append(jogador.inventario, [item]))
}

// Remove um, somente um, item do inventário
pub fn gastar_item(jogador: Jogador, item: String) -> Jogador {
  Jogador(
    ..jogador,
    inventario: remover(jogador.inventario, item),
  )
}

// Remove somente a primeira aparição de um item
fn remover(inventario: List(String), item: String) -> List(String) {
  case inventario, prim == item {
    [], _ -> []
    [_, ..resto], True -> resto
    [prim, ..resto], False -> [prim, ..remover(resto, item)]
  }
}

// Verifica se o jogador, anteriormente, já viu a *pista*
pub fn possui_pista(jogador: Jogador, pista: String) -> Bool {
  lista_contem(jogador.pistas_descobertas, pista)
}

// Registra uma *pista* descoberta
pub fn adicionar_pista(jogador: Jogador, pista: String) -> Jogador {
  case possui_pista(jogador, pista) {
    True -> jogador
    False ->
      Jogador(
        ..jogador,
        pistas_descobertas: list.append(jogador.pistas_descobertas, [pista]),
      )
  }
}

// Verifica se o *enigma* está entre os resolvidos
pub fn ja_resolveu_enigma(jogador: Jogador, enigma: String) -> Bool {
  lista_contem(jogador.enigmas_resolvidos, enigma)
}

// Registra um *enigma* resolvido
pub fn registrar_enigma_resolvido(jogador: Jogador, enigma: String) -> Jogador {
  case ja_resolveu_enigma(jogador, enigma) {
    True -> jogador
    False ->
      Jogador(
        ..jogador,
        enigmas_resolvidos: list.append(jogador.enigmas_resolvidos, [enigma]),
      )
  }
}

// mata o jogador
pub fn morrer(jogador: Jogador) -> Jogador {
  Jogador(..jogador, vida: False)
}


// Atualiza a localização do jogador
pub fn trocar_localizacao(jogador: Jogador, loc: String) -> Jogador {
  Jogador(..jogador, localizacao: loc)
}
