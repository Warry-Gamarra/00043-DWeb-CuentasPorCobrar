using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;//No deberia estar el MVC

namespace WebApp.ViewModels
{
    public class PeriodoViewModel
    {
        public int I_PeriodoID { get; set; }
        public string T_CuotaPagoDesc { get; set; }
        public short N_Anio { get; set; }
        public DateTime D_FecIni { get; set; }
        public DateTime D_FecFin { get; set; }

        //public string Descripcion { get; set; }
        //public string Nro_Cuenta_Corriente { get; set; }
        //public string Codigo_Banco { get; set; }
        //public int Prioridad { get; set; }
    }

    public class NuevoPeriodoViewModel
    {
        [Display(Name = "Descripción")]
        public int I_CuotaPagoID { get; set; }
        [Display(Name = "Año")]
        public short N_Anio { get; set; }
        [Display(Name = "Fecha inicio")]
        public DateTime D_FecIni { get; set; }
        [Display(Name = "Fecha fin")]
        public DateTime D_FecFin { get; set; }
    }

    public class EdicionPeriodoViewModel
    {
        public int I_PeriodoID { get; set; }
        public int I_CuotaPagoID { get; set; }
        public short N_Anio { get; set; }
        public DateTime D_FecIni { get; set; }
        public DateTime D_FecFin { get; set; }
        public bool B_Habilitado { get; set; }
    }

    public static class General
    {
        public static List<ObligacionViewModel> llenar_lista_obligaciones()
        {
            var lista = new List<ObligacionViewModel>();

            lista.Add(new ObligacionViewModel()
            {
                Id = 1
            });

            lista.Add(new ObligacionViewModel()
            {
                Id = 2
            });

            lista.Add(new ObligacionViewModel()
            {
                Id = 3
            });

            return lista;
        }

        public static SelectList Listar_Anios()
        {
            var lista = new List<SelectListItem>();

            for (int i = DateTime.Now.Year; 1963 < i; i--)
            {
                var item = new SelectListItem()
                {
                    Text = i.ToString(),
                    Value = i.ToString()
                };

                lista.Add(item);
            }

            return new SelectList(lista, "Value", "Text");
        }

        public static SelectList Listar_Periodos_Academicos()
        {
            var lista = new List<SelectListItem>();

            lista.Add(new SelectListItem()
            {
                Text = "ADELANTO",
                Value = "1"
            });

            lista.Add(new SelectListItem()
            {
                Text = "ANUAL",
                Value = "2"
            });

            lista.Add(new SelectListItem()
            {
                Text = "APLAZADO",
                Value = "3"
            });

            lista.Add(new SelectListItem()
            {
                Text = "CICLO ESPECIAL",
                Value = "4"
            });

            lista.Add(new SelectListItem()
            {
                Text = "CICLO EXTRAORDINARIO",
                Value = "5"
            });

            lista.Add(new SelectListItem()
            {
                Text = "NIVELACIÓN",
                Value = "6"
            });

            lista.Add(new SelectListItem()
            {
                Text = "SEMESTRAL 1",
                Value = "7"
            });

            lista.Add(new SelectListItem()
            {
                Text = "SEMESTRAL 2",
                Value = "8"
            });

            return new SelectList(lista, "Value", "Text");
        }

        public static SelectList Lista_Vacia()
        {
            var lista = new List<SelectListItem>();

            lista.Add(new SelectListItem()
            {
                Text = "",
                Value = ""
            });

            return new SelectList(lista, "Value", "Text");
        }
    }
}