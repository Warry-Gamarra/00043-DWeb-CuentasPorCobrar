using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ClasificadorViewModel
    {
        public int? Id { get; set; }
        public string CodClasificador { get; set; }
        public string Descripcion { get; set; }
        public string DescripDetalle { get; set; }
        public string AnioEjercicio { get; set; }
        public string CodigoEquivalente { get; set; }
        public bool Habilitado { get; set; }

        public ClasificadorViewModel() { }

        public ClasificadorViewModel(ClasificadorDeIngreso clasificadorDeIngreso) {
            this.Id = clasificadorDeIngreso.Id;
            this.CodClasificador = clasificadorDeIngreso.CodClasificador;
            this.CodigoEquivalente = clasificadorDeIngreso.CodigoUnfv;
            this.Habilitado = clasificadorDeIngreso.Habilitado;
            this.Descripcion = clasificadorDeIngreso.Descripcion;
            this.AnioEjercicio = clasificadorDeIngreso.AnioEjercicio;
        }

    }


    public class ClasificadorRegistrarViewModel
    {
        public int? Id { get; set; }
        [Display(Name = "Código MEF")]
        [Required]
        public string CodClasificador { get; set; }

        [Display(Name = "Descripción")]
        [Required]
        public string Descripcion { get; set; }

        [Display(Name = "Descripción")]
        public string DescripDetalle { get; set; }

        [Display(Name = "Ejercicio (Año)")]
        public string AnioEjercicio { get; set; }
        [Display(Name = "Equivalente UNFV")]
        [Required]
        public string CodigoEquivalente { get; set; }

        public ClasificadorRegistrarViewModel() { }

        public ClasificadorRegistrarViewModel(ClasificadorDeIngreso clasificadorDeIngreso)
        {
            this.Id = clasificadorDeIngreso.Id;
            this.CodClasificador = clasificadorDeIngreso.CodClasificador;
            this.CodigoEquivalente = clasificadorDeIngreso.CodigoUnfv;
            this.Descripcion = clasificadorDeIngreso.Descripcion;
            this.AnioEjercicio = clasificadorDeIngreso.AnioEjercicio;
        }

    }
}