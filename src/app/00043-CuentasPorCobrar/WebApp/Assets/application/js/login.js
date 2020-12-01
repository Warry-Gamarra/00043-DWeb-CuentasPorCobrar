const inputs = document.querySelectorAll('.input');


function focusFunc() {
  let parent = this.parentNode.parentNode;
    parent.classList.add('focus');
}

function blurFunc() {
  let parent = this.parentNode.parentNode;
  if(this.value =='')
    parent.classList.remove('focus');
}

inputs.forEach(input => {
  if (input.value !== '') {
      let parent = input.parentNode.parentNode;
      parent.classList.add('focus');
  }

  input.addEventListener('focus', focusFunc);
  input.addEventListener('blur', blurFunc);
});