# README

Here are some projects that I've done at App Academy.

### Here's how to use the contents of this file.

0. Install [Ruby](https://www.ruby-lang.org/en/) (if you haven't already)-- these games are written in Ruby.

1. Clone/fork/download the zip file of this repo and open it up on your machine.

2. Open the terminal.

3. In the terminal, navigate to "A_A_projects" (or whatever you named it).

  ```
  $ cd ~/Downloads/A_A_projects
  ```

4. Play a game.

  *You can exit any game by typing "quit".*


  To play Chess:

  ```
  $ ruby chess/chess_game.rb
  ```


  To play Checkers:
  ```
  $ ruby checkers/checkers_game.rb
  ```
  

  To play Minesweeper:
  ```
  $ ruby minesweeper/minesweeper.rb
  ```
  
  
  To play Poker:
  ```
  $ ruby poker/lib/poker_game.rb
  ```
  

  To play Hangman:
  ```
  $ ruby hangman/hangman.rb
  ```


  To play Mastermind:
  ```
  $ ruby mastermind/mastermind.rb
  ```

  
  
  
#### Advanced: Play checkers via sockets and ports.
  
Extra set up is required to play this game. The files, as they are currently configured, will only play through one machine (both players need to be on one machine). But through a LAN connection, this game can easily be played on two machines. Both machines must have the appropriate folder downloaded, and the hostname and port must be configured the same.

On the "server":

  ```
  $ ruby checkers_sockets/checkers_game.rb server
  ```
  
  
On the "client":  

  ```
  $ ruby checkers_sockets/checkers_game.rb client
  ```
  
The "server" player must run the file first, then the "client" player. The game will not start without a client player.  
  
### Enjoy!