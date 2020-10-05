using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class UserManualViewModel
    {
        public int rutaID { get; set; }

        [Display(Name = "Nombre del Archivo")]
        [StringLength(200)]
        public string fileName { get; set; }

        [Display(Name = "Dirección url de archivo")]
        public string filePath { get; set; }

        [Display(Name = "Estado")]
        public bool habilitado { get; set; }

        //[Display(Name = "Compartido con")]
        //public IList<RolesUsuario> roles { get; set; }

    }
}