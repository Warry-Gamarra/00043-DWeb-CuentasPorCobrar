using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class SeleccionarArchivoViewModel
    {
        public string Color { get; set; }
        public TipoAlumno TipoAlumno { get; set; }
        public TipoArchivoAlumno TipoArchivoAlumno { get; set; }
        public string Action { get; set; }
    }
}