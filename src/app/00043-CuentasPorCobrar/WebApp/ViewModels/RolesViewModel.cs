using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class RolesAsociadosViewModel
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public bool Habilitado { get; set; }

        public RolesAsociadosViewModel() { }

        public RolesAsociadosViewModel(RolAplicacion rolAplicacion, bool Habilitado)
        {
            this.RoleId = rolAplicacion.Id;
            this.RoleName = rolAplicacion.NombreRol;
            this.Habilitado = Habilitado;
        }

        public static List<RolesAsociadosViewModel> ListarRoles()
        {
            var roles = new RolAplicacion();
            var result = new List<RolesAsociadosViewModel>();

            foreach (var rol in roles.Find())
            {
                result.Add(new RolesAsociadosViewModel(rol, false));
            }

            return result;
        }
    }
}
