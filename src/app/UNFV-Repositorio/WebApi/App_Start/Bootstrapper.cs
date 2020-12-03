using Autofac;
using Autofac.Integration.WebApi;
using Domain;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using WebApi.Models;

namespace WebApi.App_Start
{
    public class Bootstrapper
    {
        public static void Run()
        {
            SetAutofacWebApiContainer();
        }

        private static void SetAutofacWebApiContainer()
        {
            var builder = new ContainerBuilder();

            RegisterServices(builder);

            IContainer container = builder.Build();

            GlobalConfiguration.Configuration.DependencyResolver = new AutofacWebApiDependencyResolver(container);
        }

        private static void RegisterServices(ContainerBuilder builder)
        {
            builder.RegisterApiControllers(Assembly.GetExecutingAssembly());

            builder.RegisterModule<CoreLibModule>();

            builder.RegisterType<AlumnoService>().As<IAlumnoService>().InstancePerRequest();
            builder.RegisterType<ProgramaUnfvService>().As<IProgramaUnfvService>().InstancePerRequest();
            builder.RegisterType<FacultadService>().As<IFacultadService>().InstancePerRequest();
            builder.RegisterType<EscuelaService>().As<IEscuelaService>().InstancePerRequest();
            builder.RegisterType<EspecialidadService>().As<IEspecialidadService>().InstancePerRequest();

            builder.RegisterType<ProgramaServiceFacade>().As<IProgramaServiceFacade>().InstancePerRequest();
            builder.RegisterType<AlumnoServiceFacade>().As<IAlumnoServiceFacade>().InstancePerRequest();
        }
    }
}
