using Data.Tables;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class RolAplicacion : IRoles
    {
        public int Id { get; set; }
        public string NombreRol { get; set; }

        private readonly Webpages_Roles _roleReposeitory;

        public RolAplicacion()
        {
            _roleReposeitory = new Webpages_Roles();
        }
        public RolAplicacion(Webpages_Roles role)
        {
            this.Id = role.RoleId;
            this.NombreRol = role.RoleName;
        }


        public List<RolAplicacion> Find()
        {
            List<RolAplicacion> result = new List<RolAplicacion>();

            foreach (var item in _roleReposeitory.Find())
            {
                result.Add(new RolAplicacion(item));
            }

            return result;
        }

        public RolAplicacion FindByUser(int userId)
        {
            return new RolAplicacion(_roleReposeitory.FindByUserId(userId));
        }
    }
}
