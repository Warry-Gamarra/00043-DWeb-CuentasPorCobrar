using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class UserViewModel
    {
        public int? UserId { get; set; }

        [Display(Name = "Nombre de la cuenta")]
        public string UserName { get; set; }

        [Display(Name = "Nombre del usuario")]
        public string Person { get; set; }

        public string NumDoc { get; set; }

        [Display(Name = "Correo")]
        public string Email { get; set; }

        public string Role { get; set; }

        [Display(Name = "Estado de la cuenta")]
        public bool? Enabled { get; set; }


        public UserViewModel() { }


        public UserViewModel(User user)
        {
            this.UserId = user.UserId;
            this.UserName = user.UserName;
            this.Person = user.Person.Nombre;
            this.Email = user.Person.correo;
            this.Role = user.Rol.NombreRol;
            this.Enabled = user.Enabled;
        }

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
        public int? DependenciaId { get; set; }

        public int? PersonId { get; set; }

        [Display(Name = "Apellidos y Nombres")]
        [Required]
        [StringLength(200, ErrorMessage = "El campo {0} tiene una longitud máxima de {1} caracteres")]
        public string PersonName { get; set; }

        [Required]
        [StringLength(250, ErrorMessage = "El campo {0} tiene una longitud máxima de {1} caracteres")]
        [Display(Name = "Correo electrónico")]
        [RegularExpression(@"[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}", ErrorMessage = "El Correo electrónico no tiene el formato correcto")]
        public string Email { get; set; }

        [Display(Name = "Rol de usuario")]
        public string RoleName { get; set; }

        [Display(Name = "Dependencia")]
        public string Dependencia { get; set; }



        public UserRegisterViewModel() { }

        public UserRegisterViewModel(User user)
        {
            this.UserId = user.UserId;
            this.UserName = user.UserName;
            this.PersonId = user.Person.Id;
            this.PersonName = user.Person.Nombre;
            this.Email = user.Person.correo;
            this.DependenciaId = user.Dependencia.Id;
            this.Dependencia = user.Dependencia.Descripcion;
            this.RoleId = user.Rol.Id;
            this.RoleName = user.Rol.NombreRol;
        }
    }
}