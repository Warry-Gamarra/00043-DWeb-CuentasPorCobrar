using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class UserViewModel
    {
    }

    public class UserDetailsViewModel
    {
    }

    public class UserRegisterViewModel
    {
        public int? UserId { get; set; }

        [Required]
        [Display(Name = "Nombre de Usuario")]
        [StringLength(50, ErrorMessage = "El campo {0} tiene una longitud máxima de {1} caracteres")]
        public string UserName { get; set; }

        [Required]
        [Display(Name = "Rol de usuario")]
        public int RoleId { get; set; }


        [Display(Name = "Dependencia")]
        public int? DependenciaID { get; set; }


        [Display(Name = "Apellidos y Nombres")]
        [Required]
        [StringLength(200, ErrorMessage = "El campo {0} tiene una longitud máxima de {1} caracteres")]
        public string PersonName { get; set; }

        [Required]
        [StringLength(250, ErrorMessage = "El campo {0} tiene una longitud máxima de {1} caracteres")]
        [Display(Name = "Correo electrónico")]
        [RegularExpression(@"[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}", ErrorMessage = "El Correo electrónico no tiene el formato correcto")]
        public string Email { get; set; }

    }
}