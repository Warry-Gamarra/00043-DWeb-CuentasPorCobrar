using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{


    public class MigracionTablasViewModel
    {
        public TablaMigracion Dependencias { get; set; } = TablaMigracion.Dependencias;
        public TablaMigracion Tasas { get; set; } = TablaMigracion.Tasas;
        public TablaMigracion Obligaciones { get; set; } = TablaMigracion.Obligaciones;

    }
}