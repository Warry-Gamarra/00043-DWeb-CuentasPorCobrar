using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class EntidadRecaudadoraViewModel
    {
        public int? Id { get; set; }
        public string NombreEntidad { get; set; }
        public bool ArchivosHabilitados { get; set; }
        public bool Habilitado { get; set; }
        public DateTime FechaActualiza { get; set; }

        public EntidadRecaudadoraViewModel() { }

        public EntidadRecaudadoraViewModel(EntidadRecaudadora entidadRecaudadora)
        {
            this.Id = entidadRecaudadora.Id;
            this.NombreEntidad = entidadRecaudadora.Nombre;
            this.Habilitado = entidadRecaudadora.Habilitado;
            this.ArchivosHabilitados = entidadRecaudadora.ArchivosEntidad;
            this.FechaActualiza = entidadRecaudadora.FechaActualiza.HasValue ? entidadRecaudadora.FechaActualiza.Value.Date : DateTime.Now.Date;
        }

    }


    public class EntidadRecaudadoraRegistroViewModel
    {
        public int? Id { get; set; }
        [Display(Name = "Nombre de la entidad")]
        [Required]
        public string NombreEntidad { get; set; }

        [Display(Name = "Habilitado")]
        public bool Habilitado { get; set; }

        [Display(Name = "Habilitar archivos para configuración")]
        public bool HabilitarArchivos { get; set; }


        public EntidadRecaudadoraRegistroViewModel() { }

        public EntidadRecaudadoraRegistroViewModel(EntidadRecaudadora entidadRecaudadora)
        {
            this.Id = entidadRecaudadora.Id;
            this.NombreEntidad = entidadRecaudadora.Nombre;
            this.Habilitado = entidadRecaudadora.Habilitado;
            this.HabilitarArchivos = entidadRecaudadora.ArchivosEntidad;
        }

    }
}