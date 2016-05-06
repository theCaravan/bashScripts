# bashScripts
Miscellaneous bash scripts used to automate work on Arch Linux

Currently, the scripts aim to revolve around a number of main concepts:

  1- A lot of logging. 
				That is so as to diagnose bugs, and give an idea on what exactly happens. 
        So it is common for the scripts to specifically request the highest level of verbosity
        
  2- Organized output. 
        This means that the "echo" commands are put in place so that there is the appropriate amount of spacing and lines. 
        That way the user not only understands where the script is at, but in an organized form.
  
  3- Optimization. 
        While not apparent at first sight, a big goal is to make the scripts run faster while producing similar outputs. 
        However, as of May 6 2016, bash scripting is new to the Caravan Systems so correctness is prioritized
        But once bash scripting is better understood, optiimization will be a very big focus.
        For example, stdout uses a lot of time. 
            If one script in an infinite loop is to incerement 1 to a value and print that value, the values are being outputted fast.
            But suppose that printing part is taken out. Run it for the same amount of time, send a keyboard interrupt and compare the values. 
                This value is much much larger then the previous one because the computer saved time not outputting text.
        But writing to files take a lot of time in of themselves, which is why in the future there will be a way to make that faster.
  
  4- Organized code.
        Like optimization, this is not emphasized because scripting in bash is new to the Caravan. 
        But it is also important that you the viewer understand what is going on. That saves time.
        Again, like in optimization, once this skill is better entrenched, the code will look better organized
  
  5- Automation
        Literally the reason why the Caravan started bash scripting in the first place
        Time is wasted every day when humans try to do things repeatedly and slowly. 
        This can accumulate to months, years, decades. This lost time can never be taken back.
        Computers today have the capability to do millions of calculations in a second. Why not take advantage of this?
  
        
How do you the viewer benefit from this?
  
  1- These scripts are licensed under the GNU GPL 3.
        Thus, you can modify these scripts as well as optimize them for your specific system
  
  2- Inspiration:
        Many people who program want to make things better, but do not know where to start
        Or, they have a specific idea but do not know how to implement in bash
  
  3- Fixing bugs:
        Everyone makes mistakes; that is why bugs exist. 
        Why else would the Caravan post code to GitHub publicly? 
        
  May 6, 2016
        
  
  
  
  
  
