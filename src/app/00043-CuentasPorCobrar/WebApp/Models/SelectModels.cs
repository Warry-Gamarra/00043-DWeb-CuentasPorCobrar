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
        private readonly IDependencia _dependencia;
        private readonly ConceptoPagoService _catalogoOpcionService;

        public SelectModels()
        {
            _roles = new RolAplicacion();
            _dependencia = new Dependencia();
            _catalogoOpcionService = new ConceptoPagoService();
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

        public List<SelectViewModel> GetPeriodosAcademicosCatalogo()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _catalogoOpcionService.Listar_CatalogoOpcion_Habilitadas_X_Parametro(Domain.DTO.Parametro.Periodo))
            {
                result.Add(new SelectViewModel() { Value = item.I_OpcionID.ToString(), TextDisplay = item.T_OpcionDesc });
            }

            return result;
        }

        public List<SelectViewModel> GetDependencias()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _dependencia.Find())
            {
                result.Add(new SelectViewModel() { Value = item.Id.ToString(), TextDisplay = item.Descripcion });
            }

            return result;
        }

    }
}