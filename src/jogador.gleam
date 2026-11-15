import list from gleam/list

pub type Jogador {
  Jogador(
    nome: String,
    local: String,
    inventario: List(String),
    pistas: List(String),
  )
}

// Adiciona um *obj*, pelo seu nome, ao inventario
pub fn adicionar_obj(player: Jogador, obj: String) -> Jogador {
  case possui_obj(player, obj) {
    True -> player
    False -> Jogador(..player, inventario: list.append(player.inventario, [obj]))
  }
}

// Remove *obj*, pelo seu nome, do inventario
pub fn gastar_obj(player: Jogador, obj: String) -> Jogador {
  Jogador(..player, inventario: list.filter(player.inventario, fn(x) {x != obj}))
}

// Registra uma *pista* descoberta
pub fn adicionar_pista(player: Jogador, pista: String) -> Jogador {
  case possui_pista(player, pista) {
    True -> player
    False -> Jogador(..player, pistas: list.append(player.pistas, [pista]))
  }
}

// Verifica se o *player* possui determinado *obj*
pub fn possui_obj(player: Jogador, obj: String) -> Bool {
  lista_contem(player.inventario, obj)
}

// Verifica se o *player* ja descobriu determinada *pista*
pub fn possui_pista(player: Jogador, pista: String) -> Bool {
  lista_contem(player.pistas, pista)
}

// Verifica se um elemento aparece em uma lista
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

// Atualiza a localizacao do *player*
pub fn mudar_local(player: Jogador, novo_loc: String) -> Jogador {
  Jogador(..player, local: novo_loc)
}