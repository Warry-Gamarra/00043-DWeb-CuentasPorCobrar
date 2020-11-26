using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class UserManualViewModel
    {
        public int RutaID { get; set; }

        [Display(Name = "Nombre del Archivo")]
        [Required]
        [StringLength(200)]
        public string FileName { get; set; }

        [Display(Name = "Dirección url de archivo")]
        [Required]
        public string FilePath { get; set; }

        [Display(Name = "Estado")]
        public bool Habilitado { get; set; }

        [Display(Name = "Compartido con")]
        public IList<RolesAsociadosViewModel> Roles { get; set; }

        public UserManualViewModel()
        {
            this.Roles = new List<RolesAsociadosViewModel>();
            var roles = new RolAplicacion();

            foreach (var rol in roles.Find())
            {
                this.Roles.Add(new RolesAsociadosViewModel(rol, false));
            }
        }

        public UserManualViewModel(HelperResources helpResources)
        {
            this.RutaID = helpResources.Id;
            this.FileName = helpResources.Documento;
            this.FilePath = helpResources.Url;
            this.Habilitado = helpResources.Habilitado;

            this.Roles = new List<RolesAsociadosViewModel>();

        }

    }
}