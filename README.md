# Playing-Maze-Using-Voice-Commands

The dataset is available here: 

Requirements : MATLAB and Audio processing ToolBox in MATLAB

Steps to Run the code:

1)Model_Training_Evaluating.mlx run this file in MATLAB online
  to use pareller pool for faster processing or in local MATLAB with
  good specifications.
  
  Skip running this file as we aleady saved the trained model.
  The trained Model is named as 'model1net.mat' and provided in this folder..

2)For playing the maze using audio commands: change the MATLAB path to 
  this downloaded code folder. 

  In command window type: 'maze(row,col)' 
  here row (integer) = number of rows to be set for maze
  and col (integer) = number of columns to be set for maze

3)A new figure window with maze will pop now press any key to give audio input.
  Start giving input when title says 'Start Speaking' the audio input is only
  of '1' second duration so give the desired command in '1' second and
  the Trained model which we saved will classify the audio recorded into a
  class label and performs that action if its legal on the maze.

  Give 'STOP' command as input audio to abort the game at any point of time.

  The 'Blue' diamonds tells the traversed path by us in past actions and the
  'Black' diamond is our current position in the maze.


