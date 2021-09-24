using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class SelectModel
    {
        private readonly IRoles _roles;
        private readonly IDependencia _dependencia;
        private readonly ConceptoPagoService _conceptoPagoService;
        private readonly EntidadRecaudadora _entidadFinanciera;
        private readonly IClasificadorEquivalencia _clasificadorEquivalencia;
        private ICuentaDeposito _cuentaDeposito;

        public SelectModel()
        {
            _roles = new RolAplicacion();
            _dependencia = new Dependencia();
            _conceptoPagoService = new ConceptoPagoService();
            _entidadFinanciera = new EntidadRecaudadora();
            _clasificadorEquivalencia = new ClasificadorEquivalencia();
            _cuentaDeposito = new CuentaDeposito();
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

            foreach (var item in _conceptoPagoService.Listar_CatalogoOpcion_Habilitadas_X_Parametro(Domain.Helpers.Parametro.Periodo))
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

        public List<SelectViewModel> GetGradosAcademicos()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _conceptoPagoService.Listar_CatalogoOpcion_Habilitadas_X_Parametro(Domain.Helpers.Parametro.Grado))
            {
                result.Add(new SelectViewModel() { Value = item.I_OpcionID.ToString(), TextDisplay = item.T_OpcionDesc.ToUpper() });
            }

            return result;
        }

        public List<SelectViewModel> GetEntidadesFinancieras()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _entidadFinanciera.Find().Where(x => x.Habilitado))
            {
                result.Add(new SelectViewModel() { Value = item.Id.ToString(), TextDisplay = item.Nombre.ToUpper() });
            }

            return result;
        }

        public List<SelectViewModel> Listar_Combo_CatalogoOpcion_X_Parametro(Parametro tipoParametroID)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = _conceptoPagoService.Listar_CatalogoOpcion_Habilitadas_X_Parametro(tipoParametroID);

            if (lista != null)
            {
                result = lista.Select(x => new SelectViewModel()
                {
                    Value = x.I_OpcionID.ToString(),
                    TextDisplay = x.T_OpcionDesc
                }).ToList();
            }

            return result;
        }


        public List<SelectViewModel> GetCodigoClasificadorConceptos()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _conceptoPagoService.Listar_Concepto_All())
            {
                result.Add(new SelectViewModel() { Value = item.T_Clasificador, TextDisplay = item.T_Clasificador + " - " + item.T_ConceptoDesc.ToUpper() });
            }

            return result;
        }

        public List<SelectViewModel> GetAniosClasificador(int maxAnio)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _clasificadorEquivalencia.Find_All_Years()
                                                          .Where(x => int.Parse(x.AnioEjercicio) < maxAnio)
                                                          .Select(x => x.AnioEjercicio).Distinct())
            {
                result.Add(new SelectViewModel() { Value = item, TextDisplay = item });
            }

            return result.OrderByDescending(x => x.Value).ToList();
        }

        public List<SelectViewModel> GetCtasDeposito(int idEntidadFinanciera)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _cuentaDeposito.Find().Where(x => x.I_EntidadFinanId == idEntidadFinanciera))
            {
                result.Add(new SelectViewModel() { Value = item.I_CtaDepID.ToString(), TextDisplay = item.C_NumeroCuenta });
            }

            return result;
        }

        public List<SelectViewModel> GetCondicionesPago()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _conceptoPagoService.Listar_CatalogoOpcion_Habilitadas_X_Parametro(Domain.Helpers.Parametro.CondicionPago))
            {
                result.Add(new SelectViewModel() { Value = item.I_OpcionID.ToString(), TextDisplay = item.T_OpcionDesc });
            }

            return result;
        }
    }
}