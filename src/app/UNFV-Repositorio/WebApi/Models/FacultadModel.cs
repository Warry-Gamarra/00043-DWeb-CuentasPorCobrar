using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public class FacultadModel
    {
        public string CodFac { get; set; }
        public string FacDesc { get; set; }
        public string FacAbrev { get; set; }
        public int? DependenciaID { get; set; }
        public bool Habilitado { get; set; }
    }
}