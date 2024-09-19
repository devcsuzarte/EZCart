EZCart é um aplicativo que utiliza reconhecimento de texto e machine learning para gerar um carrinho de compras virtual a partir de etiquetas de mercado.

Para desenvolver este app, utilizei o framework Vision, disponibilizado pela própria Apple, para obter o texto da etiqueta.

Após conseguir esse texto, era necessário tratá-lo para determinar o que seria o título do produto e o preço. Para isso, utilizei o CoreML, criando um modelo de machine learning que verifica cada string e retorna a probabilidade de ser título, preço ou um texto qualquer.

Para finalizar, como o usuário pode querer manter essa lista salva em seu dispositivo, utilizei o CoreData para persistir os dados localmente.
