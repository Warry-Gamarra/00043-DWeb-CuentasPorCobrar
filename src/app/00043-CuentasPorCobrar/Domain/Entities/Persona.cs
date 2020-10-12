using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class Persona
    {
        public int? Id { get; set; }
        public string Nombre { get; set; }
        public string NumDocIdentidad { get; set; }
        public string correo { get; set; }
    }
}
