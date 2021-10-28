﻿using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class ServiceController : ApiController
    {
        private readonly ProcesoModel procesoModel;
        private readonly ConceptoPagoModel conceptoPagoModel;
        private readonly ConceptoModel conceptoModel;
        private readonly CategoriaPagoModel categoriaPagoModel;
        private readonly EstructuraArchivoModel estructuraArchivoModel;
        IObligacionServiceFacade _obligacionServiceFacade;
        ICuentaDeposito _cuentaDeposito;
        IProgramasClientFacade programasClientFacade;
        IGeneralServiceFacade generalServiceFacade;
        PagosModel pagoModel;

        public ServiceController()
        {
            procesoModel = new ProcesoModel();
            conceptoPagoModel = new ConceptoPagoModel();
            conceptoModel = new ConceptoModel();
            categoriaPagoModel = new CategoriaPagoModel();
            estructuraArchivoModel = new EstructuraArchivoModel();
            _obligacionServiceFacade = new ObligacionServiceFacade();
            _cuentaDeposito = new CuentaDeposito();
            programasClientFacade = new ProgramasClientFacade();
            generalServiceFacade = new GeneralServiceFacade();
            pagoModel = new PagosModel();
        }

        // GET: api/service/GetPrioridad/5
        public int GetPrioridad(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }

            return procesoModel.Obtener_Prioridad_Tipo_Proceso(id);
        }

        // GET: api/service/GetDefaultValuesCategoria/5
        public object GetDefaultValuesCategoria(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }
            string codBanco = categoriaPagoModel.Find(id).CodBcoComercio;
            List<SelectGroupViewModel> lista = procesoModel.Listar_Combo_CtaDepositoHabilitadas(id);
            
            return new { CodBanco = codBanco, CuentasDeposito = lista };
        }

        // GET: api/service/GetDefaultValuesConcepto/5
        public CatalogoConceptosRegistroViewModel GetDefaultValuesConcepto(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }

            var model = conceptoModel.ObtenerConcepto(id);

            return model;
        }

        // GET: api/service/GetCtasDepositoPorPeriodo?anio=2021&periodo=15
        public IEnumerable<SelectViewModel> GetCtasDepositoPorPeriodo(int anio, int? periodo, TipoEstudio tipoEstudio)
        {
            var ctasDeposito = _obligacionServiceFacade.Obtener_CtaDeposito_X_Periodo(anio, periodo, tipoEstudio);

            var entidades = ctasDeposito.GroupBy(x => x.I_EntidadFinanID);

            var result = entidades.Select(
                x => new SelectViewModel() {
                    Value = x.Key.ToString(),
                    TextDisplay = x.First().T_EntidadDesc
                });

            return result;
        }

        // GET: api/service/GetColumnasPorTabla?nombreTabla=TR_PagoBanco
        public IEnumerable<SelectViewModel> GetColumnasPorTabla(string nombreTabla)
        {
            if (string.IsNullOrEmpty(nombreTabla))
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El nombre de la tabla no puede estar vacío.")
                };

                throw new HttpResponseException(error);
            }

            var result = estructuraArchivoModel.ObtenerColumnasTabla(nombreTabla);

            return result;
        }

        // GET: api/service/GetCtasDepositoPorBco/1
        public IEnumerable<SelectViewModel> GetCtasDepositoPorBco(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("ID de banco incorrecto.")
                };

                throw new HttpResponseException(error);
            }

            var result = _cuentaDeposito.Find()
                .Where(x => x.I_EntidadFinanId == id)
                .Select(x => new SelectViewModel() {
                    Value = x.I_CtaDepID.ToString(),
                    TextDisplay = x.C_NumeroCuenta
                });

            return result;
        }

        // GET: api/service/GetFacultades?tipoEstudio=TipoEstudio
        public IEnumerable<SelectViewModel> GetFacultades(TipoEstudio tipoEstudio)
        {
            return programasClientFacade.GetFacultades(tipoEstudio);
        }

        // GET: api/service/GetDependencias?tipoEstudio=TipoEstudio
        public IEnumerable<SelectViewModel> GetDependencias(TipoEstudio tipoEstudio)
        {
            return programasClientFacade.GetDependencias(tipoEstudio);
        }

        // GET: api/service/GetEscuelas?codFac=codFac
        public IEnumerable<SelectViewModel> GetEscuelas(string codFac)
        {
            return programasClientFacade.GetEscuelas(codFac);
        }

        // GET: api/service/GetEspecialidades?codFac=codFac
        public IEnumerable<SelectViewModel> GetEspecialidades(string codFac)
        {
            return programasClientFacade.GetEspecialidades(codFac);
        }

        // GET: api/service/GetEspecialidades?codFac=codFac&codEsc=codEsc
        public IEnumerable<SelectViewModel> GetEspecialidades(string codFac, string codEsc)
        {
            return programasClientFacade.GetEspecialidades(codFac, codEsc);
        }

        // GET: api/service/GetPagosObservados?codOperacion=codOperacion&codAlumno=codAlumno
        public IEnumerable<PagoBancoObligacionViewModel> GetPagosObservados(string codOperacion, string codAlumno)
        {
            return  pagoModel.ListarPagoBancoObligacion(null, null, codOperacion, codAlumno,
                null, null, null)
                .Where(x => x.I_CondicionPagoID != (int)CatalogoTipoPago.Correcto && x.I_CondicionPagoID != (int)CatalogoTipoPago.Extorno)
                .OrderBy(x => x.T_DatosDepositante);
        }

        // GET: api/service/GetDetalleObligacionByID/id
        public ObligacionDetalleModel GetDetalleObligacionByID(int id)
        {
            return _obligacionServiceFacade.Obtener_DetalleObligacion_X_ID(id);
        }

        // GET: api/service/GetDetalleObligacionByID/id
        public List<ObligacionDetalleModel> GetDetalleObligacion(int id)
        {
            return _obligacionServiceFacade.Obtener_DetalleObligacion_X_Obligacion(id);
        }
    }
}
