import gleam/io
import gleam/string

import jogo
import ambiente

// Opções do menu principal
pub type MainMenu {
  Explorar
  Inventario
  Enigmas
  Sair
}

// Resultado de uma opção do menu
pub type ResultadoMenu {
  Mostrar(mensagem: String)
  Encerrar
}

// Apresenta o menu
pub fn display_main_menu() {
  io.println("\n--- MENU PRINCIPAL ---")
  io.println("m1(): Explorar ambiente")
  io.println("m2(): Consultar inventário")
  io.println("m3(): Examinar enigmas")
  io.println("exit(): Encerrar simulação")
}

// Seleciona as opções
pub fn m1() -> MainMenu {
  Explorar
}

pub fn m2() -> MainMenu {
  Inventario
}

pub fn m3() -> MainMenu {
  Enigmas
}

pub fn exit() -> MainMenu {
  Sair
}

// Executa a opção escolhida
pub fn executar_opcao(estado: jogo.EstadoJogo, opcao: MainMenu) -> Result(#(jogo.EstadoJogo, ResultadoMenu), Nil) {
  case opcao {
    Explorar -> {
      case jogo.explorar_atual(estado) {
        Ok(texto) ->
          Ok(#(estado, Mostrar(texto)))
        Error(Nil) -> Error(Nil)
      }
    }

    Inventario -> {
      let itens = estado.jogador.inventario

      let texto = case itens {
        [] -> "Seu inventário está vazio."
        _ -> "Inventário: " <> string.join(itens, ", ")
      }

      Ok(#(estado, Mostrar(texto)))
    }

    Enigmas -> {
      case jogo.buscar_ambiente_atual(estado) {
        Ok(local) -> {
          let enigmas = ambiente.listar_enigmas(local)

          let texto = case enigmas {
            [] -> "Não existem enigmas neste ambiente."
            _ -> "Enigmas disponíveis: " <> string.join(enigmas, ", ")
          }

          Ok(#(estado, Mostrar(texto)))
        }

        Error(Nil) -> Error(Nil)
      }
    }

    Sair -> Ok(#(estado, Encerrar))
  }
}
