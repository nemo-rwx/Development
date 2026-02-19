import React from 'react'

const Createtodo = () => {
    const task = 0;
    const counttask = () => {
        // if (task == 0) {
        //     return "No Task Available" ;
        // }else{
        //     return `Task: ${task}`;
        // }

        return task == 0 ? " No Task Available" : `Task : ${task}`;
            
    };
  return (
    <div><h1>{counttask()}</h1>
     <button> new button</button>
     </div>
  )
}

export default Createtodo



