using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class EntidadFinancieraViewModel
    {
        public int? Id { get; set; }
        public string NombreEntidad { get; set; }
        public bool ArchivosHabilitados { get; set; }
        public bool Habilitado { get; set; }
        public DateTime FechaActualiza { get; set; }

        public EntidadFinancieraViewModel() { }

        public EntidadFinancieraViewModel(EntidadFinanciera entidadFinanciera)
        {
            this.Id = entidadFinanciera.Id;
            this.NombreEntidad = entidadFinanciera.Nombre;
            this.Habilitado = entidadFinanciera.Habilitado;
            this.ArchivosHabilitados = entidadFinanciera.ArchivosEntidad;
            this.FechaActualiza = entidadFinanciera.FechaActualiza.HasValue ? entidadFinanciera.FechaActualiza.Value.Date : DateTime.Now.Date;
        }

    }


    public class EntidadFinancieraRegistroViewModel
    {
        public int? Id { get; set; }
        [Display(Name = "Nombre de la entidad")]
        [Required]
        public string NombreEntidad { get; set; }

        [Display(Name = "Estado")]
        public bool Habilitado { get; set; }

        [Display(Name = "Tipos de archivo")]
        public bool HabilitarArchivos { get; set; }


        public EntidadFinancieraRegistroViewModel() { }

        public EntidadFinancieraRegistroViewModel(EntidadFinanciera entidadFinanciera)
        {
            this.Id = entidadFinanciera.Id;
            this.NombreEntidad = entidadFinanciera.Nombre;
            this.Habilitado = entidadFinanciera.Habilitado;
            this.HabilitarArchivos = entidadFinanciera.ArchivosEntidad;
        }

    }
}