using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class SelectModels
    {
        private readonly IRoles _roles;

        public SelectModels()
        {
            _roles = new RolAplicacion();
        }

        public List<SelectViewModel> GetRoles()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _roles.Find())
            {
                result.Add(new SelectViewModel()
                {
                    Value = item.Id.ToString(),
                    TextDisplay = item.NombreRol
                });
            }

            return result;
        }


        public List<SelectViewModel> GetAnios(int anioMinimo)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            for (int anio = DateTime.Now.Year; anio >= anioMinimo; anio--)
            {
                result.Add(new SelectViewModel()
                {
                    Value = anio.ToString(),
                    TextDisplay = anio.ToString()
                });
            }

            return result;
        }
    }
}