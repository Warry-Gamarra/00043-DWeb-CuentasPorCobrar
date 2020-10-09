using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;//No deberia estar el MVC

namespace WebApp.ViewModels
{
    public class PeriodoViewModel
    {
        public int Id { get; set; }
        public string Descripcion { get; set; }
        public string Nro_Cuenta_Corriente { get; set; }
        public string Codigo_Banco { get; set; }
        public DateTime Fecha_Vencimiento { get; set; }
        public int Prioridad { get; set; }
    }

    public static class General
    {
        public static List<PeriodoViewModel> llenar_lista_periodos()
        {
            var lista = new List<PeriodoViewModel>();

            lista.Add(new PeriodoViewModel()
            {
                Id = 1,
                Descripcion = "Matricula 2019 - Semestre 1",
                Nro_Cuenta_Corriente = "123456789",
                Codigo_Banco = "123",
                Fecha_Vencimiento = DateTime.Now,
                Prioridad = 1
            });

            lista.Add(new PeriodoViewModel()
            {
                Id = 2,
                Descripcion = "Matricula 2019 - Semestre 2",
                Nro_Cuenta_Corriente = "123456789",
                Codigo_Banco = "123",
                Fecha_Vencimiento = DateTime.Now,
                Prioridad = 1
            });

            lista.Add(new PeriodoViewModel()
            {
                Id = 3,
                Descripcion = "Matricula 2020 - Semestre 1",
                Nro_Cuenta_Corriente = "123456789",
                Codigo_Banco = "123",
                Fecha_Vencimiento = DateTime.Now,
                Prioridad = 1
            });

            return lista;
        }

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