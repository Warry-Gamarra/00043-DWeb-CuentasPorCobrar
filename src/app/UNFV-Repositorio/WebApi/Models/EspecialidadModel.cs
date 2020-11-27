using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public class EspecialidadModel
    {
        public string CodEsp { get; set; }
        public string CodEsc { get; set; }
        public string CodFac { get; set; }
        public string EspDesc { get; set; }
        public string EspAbrev { get; set; }
        public bool Habilitado { get; set; }
    }
}