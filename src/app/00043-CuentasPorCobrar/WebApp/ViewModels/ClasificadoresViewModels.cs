﻿using Domain.Entities;
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
        public string CodigoEquivalente { get; set; }
        public bool Habilitado { get; set; }

        public ClasificadorViewModel() { }

        public ClasificadorViewModel(ClasificadorPresupuestal clasificador) {
            this.Id = clasificador.Id;
            this.CodClasificador = clasificador.CodClasificador;
            this.CodigoEquivalente = clasificador.CodigoUnfv;
            this.Habilitado = clasificador.Habilitado;
            this.Descripcion = clasificador.Descripcion;
            this.DescripDetalle = clasificador.DescripDetalle;
        }

    }


    public class ClasificadorRegistrarViewModel
    {
        public int? Id { get; set; }

        [Display(Name = "Tipo tran.")]
        [Required]
        [Range(1, 9)]
        public int TipoTransaccion { get; set; }

        [Display(Name = "Genérica")]
        [Required]
        [Range(1, 9)]
        public int Generica { get; set; }

        [Display(Name = "SubGenérica")]
        [Range(1, 9999)]
        public int? SubGenerica { get; set; }

        [Display(Name = "Específica")]
        [Range(1,9999)]
        public int? Especifica { get; set; }

        [Display(Name = "Descripción")]
        [Required]
        public string Descripcion { get; set; }

        [Display(Name = "Descripción detallada")]
        public string DescripDetalle { get; set; }


        public ClasificadorRegistrarViewModel() { }

        public ClasificadorRegistrarViewModel(ClasificadorPresupuestal clasificador)
        {
            this.Id = clasificador.Id;
            this.TipoTransaccion = Convert.ToInt32(clasificador.TipoTransCod);
            this.Generica = Convert.ToInt32(clasificador.GenericaCod);
            this.SubGenerica = Convert.ToInt32(clasificador.SubGeneCod);
            this.Especifica = Convert.ToInt32(clasificador.EspecificaCod);
            this.Descripcion = clasificador.Descripcion;
            this.DescripDetalle = clasificador.DescripDetalle;
        }

    }
}